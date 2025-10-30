//
//  AppFota.swift
//  BLEScanner
//
//  Created by rafael_sw on 2021/4/7.
//

import Foundation
import UIKit
import CoreBluetooth
import BLEFramework

class AppFota: UIViewController, BLEFramework.BLEServiceDelegate {

    @IBOutlet weak var selBinBtn: UIButton!
    @IBOutlet weak var checkVersionBtn: UIButton!
    @IBOutlet weak var checkBank1Btn: UIButton!
    @IBOutlet weak var EraseBtn: UIButton!
    @IBOutlet weak var downloadFwBtn: UIButton!
    @IBOutlet weak var crcCheckBtn: UIButton!
    @IBOutlet weak var selBinIndicator: UIActivityIndicatorView!
    @IBOutlet weak var checkVersionIndicator: UIActivityIndicatorView!
    @IBOutlet weak var checkBank1Indicator: UIActivityIndicatorView!
    @IBOutlet weak var downloadFwIndicator: UIActivityIndicatorView!
    @IBOutlet weak var crcCheckIndicator: UIActivityIndicatorView!
    @IBOutlet weak var logView: UITextView!
    @IBOutlet weak var led: UIBarButtonItem!
    
    public var bleFramework : BLEFramework!
    private var disconnectflag = false
    override func viewDidLoad() {
        super.viewDidLoad()
        bleFramework.RegisterBLE(self)
    }
    
    @IBAction func selBinBtn(_ sender: Any) {
        Task { @MainActor in
            var num = 0
            var alert: UIAlertController?
            selBinIndicator.startAnimating()
            checkVersionBtn.isEnabled = false
            
            do {
                (alert, num) = try await bleFramework.SelectBin()
                if num > 0 {
                    await MainActor.run {
                        self.present(alert!, animated: true)
                    }
                    
                    while !bleFramework.selectBinDone {
                        try? await Task.sleep(nanoseconds: 500_000_000)
                    }
                    
                    await MainActor.run {
                        if self.bleFramework.binInUse != "" {
                            self.checkVersionBtn.isEnabled = true
                        }
                        self.selBinIndicator.stopAnimating()
                    }
                } else {
                    await MainActor.run {
                        self.selBinIndicator.stopAnimating()
                    }
                }
            } catch {
                print("Error selecting bin: \(error)")
                await MainActor.run {
                    self.selBinIndicator.stopAnimating()
                    checkVersionBtn.isEnabled = true
                }
            }
            
        }
    }
    
    @IBAction func checkVersionBtn(_ sender: Any) {
        self.checkVersionIndicator.startAnimating()
        self.checkBank1Btn.isEnabled = false
        self.EraseBtn.isEnabled = false
        bleFramework.CheckVersion()
        let checkVersionQueue: DispatchQueue = DispatchQueue(label: "checkVersion")
        checkVersionQueue.async (){ ()-> Void in
            while (self.bleFramework.fotaInUse){
                
            }
            DispatchQueue.main.async(execute: {
                if self.bleFramework.checkVersionGoNext
                {
                    self.checkBank1Btn.isEnabled = true
                    self.EraseBtn.isEnabled = true
                }
                self.checkVersionIndicator.stopAnimating()
                self.logView.text = self.bleFramework.log
            })
        }
    }
    
    @IBAction func checkBank1Btn(_ sender: Any) {
        self.checkBank1Indicator.startAnimating()
        self.downloadFwBtn.isEnabled = false
        bleFramework.CheckBank1State()
        let checkBank1Queue: DispatchQueue = DispatchQueue(label: "checkBank1")
        checkBank1Queue.async (){ ()-> Void in
            while (self.bleFramework.fotaInUse){
                
            }
            DispatchQueue.main.async(execute: {
                if self.bleFramework.checkBank1GoNext
                {
                    self.downloadFwBtn.isEnabled = true
                }
                self.checkBank1Indicator.stopAnimating()
            })
        }
    }
    
    @IBAction func EraseBtn(_ sender: Any) {
        bleFramework.EraseBank1()
        sleep(2)
    }
    
    @IBAction func downloadFwBtn(_ sender: Any) {
        self.downloadFwIndicator.startAnimating()
        self.crcCheckBtn.isEnabled = false
        bleFramework.DownloadFW()
        let downloadFwQueue: DispatchQueue = DispatchQueue(label: "downloadFw")
        downloadFwQueue.async (){ ()-> Void in
            while (self.bleFramework.fotaInUse){
                
            }
            DispatchQueue.main.async(execute: {
                if self.bleFramework.downloadFwGoNext
                {
                    self.crcCheckBtn.isEnabled = true
                }
                self.downloadFwIndicator.stopAnimating()
            })
        }
    }
    
    @IBAction func crcCheckBtn(_ sender: Any) {
        self.crcCheckIndicator.startAnimating()
        bleFramework.ApplyReboot()
        let applyRebootQueue: DispatchQueue = DispatchQueue(label: "applyReboot")
        applyRebootQueue.async (){ ()-> Void in
            while (self.bleFramework.fotaInUse){
                
            }
            DispatchQueue.main.async(execute: {
                self.crcCheckIndicator.stopAnimating()
            })
        }
    }
    
    func BLECentralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == bleFramework.peripheralInUse
        {
            disconnectflag = false
            let connectQueue: DispatchQueue = DispatchQueue(label: "connect")
            connectQueue.async (){ ()-> Void in
                sleep(1)
                self.bleFramework.SetNotify(to: peripheral, characteristic: self.bleFramework.fotaInUseWriteNotify, enabled: true)
                self.bleFramework.SetNotify(to: peripheral, characteristic: self.bleFramework.fotaInUseWriteIndicate, enabled: true)
                DispatchQueue.main.async(execute: {
                    self.led.tintColor = .systemGreen
                    self.view.isUserInteractionEnabled = true
                })
            }
        }
    }
    
    func BLECentralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        if peripheral == bleFramework.peripheralInUse
        {
            DispatchQueue.main.async(execute: {
                self.led.tintColor = .darkGray
                self.view.isUserInteractionEnabled = false
                self.downloadFwBtn.isEnabled = false
            })
            disconnectflag = true
            sleep(1)
            bleFramework.Disconnect(to: bleFramework.peripheralInUse)
            bleFramework.Connect(to: bleFramework.peripheralInUse)
            
            let connectCheckQueue: DispatchQueue = DispatchQueue(label: "connectCheck")
            connectCheckQueue.async (){ ()-> Void in
                    var loop = 0
                    var startTime = self.bleFramework.GetTimeMs()
                    while (self.disconnectflag)
                    {
                        let stopTime = self.bleFramework.GetTimeMs()
                        if (stopTime - startTime) > 6000
                        {
                            startTime = stopTime
                            self.bleFramework.Connect(to: self.bleFramework.peripheralInUse)
                            loop += 1
                        }
                        
                        if (loop > 2)
                        {
                            break
                        }
                    }
                }
            }
    }
    
    func BLECentralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
    }
}
