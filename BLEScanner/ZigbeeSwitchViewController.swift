//
//  ZigbeeSwitch.swift
//  BLEScanner
//
//  Created by rafael_sw on 2022/3/11.
//

import Foundation
import UIKit
import CoreBluetooth
import BLEFramework

class ZigbeeSwitchViewController: UIViewController, BLEFramework.BLEServiceDelegate {
    
    public var bleFramework : BLEFramework!
    private var disconnectflag = false
    
    public var deviceInUseUUID = ""
    private var serviceInUse: CBService!
    private var serviceTitles: [String] = []
    private var serviceUUIDs: [String] = []
    private var serviceSubtitles: [String] = []
    private var services: [CBService] = []
    
    public var charInUse: CBCharacteristic!
    public var hasRead: Bool = false
    public var hasWrite: Bool = false
    public var hasWriteWoRes: Bool = false
    public var hasNotify: Bool = false
    private var writeCmd = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for service in bleFramework.peripheralInUse.services! {
            services.append(service)
            //print("uuid: ",service.uuid.uuidString)
        }
        
    }
    
    @IBAction func btn1(_ sender: Any) {
        writeCmd = "Button1"
        WriteData(writeType: .withoutResponse)
    }
    
    @IBAction func btn2(_ sender: Any) {
        writeCmd = "Button2"
        WriteData(writeType: .withoutResponse)
    }
    
    @IBAction func btn3(_ sender: Any) {
        writeCmd = "Button3"
        WriteData(writeType: .withoutResponse)
    }
    
    @IBAction func btn4(_ sender: Any) {
        writeCmd = "Button4"
        WriteData(writeType: .withoutResponse)
    }
    
    private func WriteData(writeType: CBCharacteristicWriteType)
    {
        let setCmdQueue: DispatchQueue = DispatchQueue(label: "setCmd")
        setCmdQueue.async (){ ()-> Void in
            if self.bleFramework.WriteData(to: self.bleFramework.peripheralInUse, (self.writeCmd.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)))!, characteristic: self.charInUse, writeType: writeType, waitRx: false)
            {
                
            }
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
                    //self.led.tintColor = .systemGreen
                    //self.view.isUserInteractionEnabled = true
                })
            }
        }
    }
    
    func BLECentralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        if peripheral == bleFramework.peripheralInUse
        {
            DispatchQueue.main.async(execute: {
                //self.led.tintColor = .darkGray
                //self.view.isUserInteractionEnabled = false
                //self.downloadFwBtn.isEnabled = false
            })
            disconnectflag = true
            sleep(1)
            bleFramework.Disconnect(to: bleFramework.peripheralInUse)
            bleFramework.Connect(to: bleFramework.peripheralInUse)
        }
    }
    
    func BLECentralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
    }
}
