////
////  AppFota.swift
////  BLEScanner
////
////  Created by rafael_sw on 2021/4/7.
////
//
//import Foundation
//import UIKit
//import CoreBluetooth
//
//class AppFota: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
//
//    @IBOutlet weak var selBinBtn: UIButton!
//    @IBOutlet weak var checkVersionBtn: UIButton!
//    @IBOutlet weak var checkBank1Btn: UIButton!
//    @IBOutlet weak var EraseBtn: UIButton!
//    @IBOutlet weak var downloadFwBtn: UIButton!
//    @IBOutlet weak var crcCheckBtn: UIButton!
//    @IBOutlet weak var selBinIndicator: UIActivityIndicatorView!
//    @IBOutlet weak var checkVersionIndicator: UIActivityIndicatorView!
//    @IBOutlet weak var checkBank1Indicator: UIActivityIndicatorView!
//    @IBOutlet weak var downloadFwIndicator: UIActivityIndicatorView!
//    @IBOutlet weak var crcCheckIndicator: UIActivityIndicatorView!
//    @IBOutlet weak var logView: UITextView!
//    @IBOutlet weak var led: UIBarButtonItem!
//    
//    // BLE properties
//    public var centralManager: CBCentralManager?
//    public var peripheralInUse: CBPeripheral?
//    public var fotaInUseWriteNotify: CBCharacteristic?
//    public var fotaInUseWriteIndicate: CBCharacteristic?
//    
//    // FOTA properties
//    private var disconnectflag = false
//    private var fotaInUse = false
//    private var selectBinDone = false
//    private var binInUse = ""
//    private var checkVersionGoNext = false
//    private var checkBank1GoNext = false
//    private var downloadFwGoNext = false
//    private var log = ""
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Initialize if needed
//    }
//    
//    private func GetTimeMs() -> Int64 {
//        return Int64(Date().timeIntervalSince1970 * 1000)
//    }
//    
//    @IBAction func selBinBtn(_ sender: Any) {
//        Task { @MainActor in
//            selBinIndicator.startAnimating()
//            checkVersionBtn.isEnabled = false
//            
//            // TODO: Implement file selection
//            // For now, show a placeholder alert
//            let alert = UIAlertController(title: "Select Binary", message: "File selection needs to be implemented", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
//                self.selBinIndicator.stopAnimating()
//                self.checkVersionBtn.isEnabled = true
//            })
//            self.present(alert, animated: true)
//        }
//    }
//    
//    @IBAction func checkVersionBtn(_ sender: Any) {
//        self.checkVersionIndicator.startAnimating()
//        self.checkBank1Btn.isEnabled = false
//        self.EraseBtn.isEnabled = false
//        
//        // TODO: Implement version check
//        CheckVersion()
//        
//        let checkVersionQueue: DispatchQueue = DispatchQueue(label: "checkVersion")
//        checkVersionQueue.async { [weak self] in
//            guard let self = self else { return }
//            while self.fotaInUse { }
//            DispatchQueue.main.async {
//                if self.checkVersionGoNext {
//                    self.checkBank1Btn.isEnabled = true
//                    self.EraseBtn.isEnabled = true
//                }
//                self.checkVersionIndicator.stopAnimating()
//                self.logView.text = self.log
//            }
//        }
//    }
//    
//    private func CheckVersion() {
//        // TODO: Implement actual version check logic
//        fotaInUse = true
//        DispatchQueue.global().async { [weak self] in
//            guard let self = self else { return }
//            sleep(1)
//            self.log += "Version check placeholder\n"
//            self.checkVersionGoNext = true
//            self.fotaInUse = false
//        }
//    }
//    
//    @IBAction func checkBank1Btn(_ sender: Any) {
//        self.checkBank1Indicator.startAnimating()
//        self.downloadFwBtn.isEnabled = false
//        
//        CheckBank1State()
//        
//        let checkBank1Queue: DispatchQueue = DispatchQueue(label: "checkBank1")
//        checkBank1Queue.async { [weak self] in
//            guard let self = self else { return }
//            while self.fotaInUse { }
//            DispatchQueue.main.async {
//                if self.checkBank1GoNext {
//                    self.downloadFwBtn.isEnabled = true
//                }
//                self.checkBank1Indicator.stopAnimating()
//            }
//        }
//    }
//    
//    private func CheckBank1State() {
//        // TODO: Implement actual bank1 check logic
//        fotaInUse = true
//        DispatchQueue.global().async { [weak self] in
//            guard let self = self else { return }
//            sleep(1)
//            self.log += "Bank1 check placeholder\n"
//            self.checkBank1GoNext = true
//            self.fotaInUse = false
//        }
//    }
//    
//    @IBAction func EraseBtn(_ sender: Any) {
//        EraseBank1()
//        sleep(2)
//    }
//    
//    private func EraseBank1() {
//        // TODO: Implement actual erase logic
//        log += "Erase Bank1 placeholder\n"
//    }
//    
//    @IBAction func downloadFwBtn(_ sender: Any) {
//        self.downloadFwIndicator.startAnimating()
//        self.crcCheckBtn.isEnabled = false
//        
//        DownloadFW()
//        
//        let downloadFwQueue: DispatchQueue = DispatchQueue(label: "downloadFw")
//        downloadFwQueue.async { [weak self] in
//            guard let self = self else { return }
//            while self.fotaInUse { }
//            DispatchQueue.main.async {
//                if self.downloadFwGoNext {
//                    self.crcCheckBtn.isEnabled = true
//                }
//                self.downloadFwIndicator.stopAnimating()
//            }
//        }
//    }
//    
//    private func DownloadFW() {
//        // TODO: Implement actual firmware download logic
//        fotaInUse = true
//        DispatchQueue.global().async { [weak self] in
//            guard let self = self else { return }
//            sleep(2)
//            self.log += "Firmware download placeholder\n"
//            self.downloadFwGoNext = true
//            self.fotaInUse = false
//        }
//    }
//    
//    @IBAction func crcCheckBtn(_ sender: Any) {
//        self.crcCheckIndicator.startAnimating()
//        
//        ApplyReboot()
//        
//        let applyRebootQueue: DispatchQueue = DispatchQueue(label: "applyReboot")
//        applyRebootQueue.async { [weak self] in
//            guard let self = self else { return }
//            while self.fotaInUse { }
//            DispatchQueue.main.async {
//                self.crcCheckIndicator.stopAnimating()
//            }
//        }
//    }
//    
//    private func ApplyReboot() {
//        // TODO: Implement actual reboot logic
//        fotaInUse = true
//        DispatchQueue.global().async { [weak self] in
//            guard let self = self else { return }
//            sleep(1)
//            self.log += "Apply reboot placeholder\n"
//            self.fotaInUse = false
//        }
//    }
//    
//    // MARK: - CBCentralManagerDelegate
//    
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        // Handle Bluetooth state changes if needed
//    }
//    
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        if peripheral == peripheralInUse {
//            disconnectflag = false
//            let connectQueue: DispatchQueue = DispatchQueue(label: "connect")
//            connectQueue.async { [weak self] in
//                guard let self = self else { return }
//                sleep(1)
//                if let char = self.fotaInUseWriteNotify {
//                    peripheral.setNotifyValue(true, for: char)
//                }
//                if let char = self.fotaInUseWriteIndicate {
//                    peripheral.setNotifyValue(true, for: char)
//                }
//                DispatchQueue.main.async {
//                    self.led.tintColor = .systemGreen
//                    self.view.isUserInteractionEnabled = true
//                }
//            }
//        }
//    }
//    
//    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
//        if peripheral == peripheralInUse {
//            DispatchQueue.main.async {
//                self.led.tintColor = .darkGray
//                self.view.isUserInteractionEnabled = false
//                self.downloadFwBtn.isEnabled = false
//            }
//            disconnectflag = true
//            sleep(1)
//            
//            if let peripheral = peripheralInUse {
//                centralManager?.cancelPeripheralConnection(peripheral)
//                centralManager?.connect(peripheral, options: nil)
//            }
//            
//            let connectCheckQueue: DispatchQueue = DispatchQueue(label: "connectCheck")
//            connectCheckQueue.async { [weak self] in
//                guard let self = self else { return }
//                var loop = 0
//                var startTime = self.GetTimeMs()
//                while self.disconnectflag {
//                    let stopTime = self.GetTimeMs()
//                    if (stopTime - startTime) > 6000 {
//                        startTime = stopTime
//                        if let peripheral = self.peripheralInUse {
//                            self.centralManager?.connect(peripheral, options: nil)
//                        }
//                        loop += 1
//                    }
//                    
//                    if loop > 2 {
//                        break
//                    }
//                }
//            }
//        }
//    }
//    
//    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        
//    }
//}
