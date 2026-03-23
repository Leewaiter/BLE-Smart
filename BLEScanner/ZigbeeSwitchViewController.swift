////
////  ZigbeeSwitch.swift
////  BLEScanner
////
////  Created by rafael_sw on 2022/3/11.
////
//
//import Foundation
//import UIKit
//import CoreBluetooth
//
//class ZigbeeSwitchViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
//    
//    // BLE properties
//    public var centralManager: CBCentralManager?
//    public var peripheralInUse: CBPeripheral?
//    private var disconnectflag = false
//    
//    public var deviceInUseUUID = ""
//    private var serviceInUse: CBService!
//    private var serviceTitles: [String] = []
//    private var serviceUUIDs: [String] = []
//    private var serviceSubtitles: [String] = []
//    private var services: [CBService] = []
//    
//    public var charInUse: CBCharacteristic!
//    public var fotaInUseWriteNotify: CBCharacteristic?
//    public var fotaInUseWriteIndicate: CBCharacteristic?
//    public var hasRead: Bool = false
//    public var hasWrite: Bool = false
//    public var hasWriteWoRes: Bool = false
//    public var hasNotify: Bool = false
//    private var writeCmd = ""
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        if let peripheral = peripheralInUse, let servicesList = peripheral.services {
//            for service in servicesList {
//                services.append(service)
//                //print("uuid: ",service.uuid.uuidString)
//            }
//        }
//    }
//    
//    @IBAction func btn1(_ sender: Any) {
//        writeCmd = "Button1"
//        WriteData(writeType: .withoutResponse)
//    }
//    
//    @IBAction func btn2(_ sender: Any) {
//        writeCmd = "Button2"
//        WriteData(writeType: .withoutResponse)
//    }
//    
//    @IBAction func btn3(_ sender: Any) {
//        writeCmd = "Button3"
//        WriteData(writeType: .withoutResponse)
//    }
//    
//    @IBAction func btn4(_ sender: Any) {
//        writeCmd = "Button4"
//        WriteData(writeType: .withoutResponse)
//    }
//    
//    private func WriteData(writeType: CBCharacteristicWriteType)
//    {
//        let setCmdQueue: DispatchQueue = DispatchQueue(label: "setCmd")
//        setCmdQueue.async { [weak self] in
//            guard let self = self,
//                  let peripheral = self.peripheralInUse,
//                  let characteristic = self.charInUse,
//                  let data = self.writeCmd.data(using: .utf8) else {
//                return
//            }
//            
//            peripheral.writeValue(data, for: characteristic, type: writeType)
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
//        if peripheral == peripheralInUse
//        {
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
//                    //self.led.tintColor = .systemGreen
//                    //self.view.isUserInteractionEnabled = true
//                }
//            }
//        }
//    }
//    
//    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
//        if peripheral == peripheralInUse
//        {
//            DispatchQueue.main.async {
//                //self.led.tintColor = .darkGray
//                //self.view.isUserInteractionEnabled = false
//                //self.downloadFwBtn.isEnabled = false
//            }
//            disconnectflag = true
//            sleep(1)
//            if let peripheral = peripheralInUse {
//                centralManager?.cancelPeripheralConnection(peripheral)
//                centralManager?.connect(peripheral, options: nil)
//            }
//        }
//    }
//    
//    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        
//    }
//}
