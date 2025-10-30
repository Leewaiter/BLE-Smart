//
//  Operation.swift
//  BLEScanner
//
//  Created by rafael_sw on 2021/4/20.
//

import Foundation
import UIKit
import CoreBluetooth
import BLEFramework

class OperationViewController: UIViewController {
    
    @IBOutlet weak var enableNotify: UIButton!
    @IBOutlet weak var disableNotify: UIButton!
    @IBOutlet weak var read: UIButton!
    @IBOutlet weak var write: UIButton!
    @IBOutlet weak var writeWithoutResponse: UIButton!
    @IBOutlet weak var stringType: UISegmentedControl!
    @IBOutlet weak var writeField: UITextField!
    @IBOutlet weak var log: UITextView!
    public var bleFramework : BLEFramework!
    public var charInUse: CBCharacteristic!
    public var hasRead: Bool = false
    public var hasWrite: Bool = false
    public var hasWriteWoRes: Bool = false
    public var hasNotify: Bool = false
    private var writeCmd = ""
    private var rxQueueInUse = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("version:",bleFramework.GetVersion())
        enableNotify.isEnabled = hasNotify
        disableNotify.isEnabled = hasNotify
        read.isEnabled = hasRead
        write.isEnabled = hasWrite
        writeWithoutResponse.isEnabled = hasWriteWoRes
        if !hasNotify
        {
            enableNotify.setTitle("N/A", for: .normal)
            disableNotify.setTitle("N/A", for: .normal)
        }
        if !hasRead
        {
            read.setTitle("N/A", for: .normal)
        }
        if !hasWrite
        {
            write.setTitle("N/A", for: .normal)
        }
        if !hasWriteWoRes
        {
            writeWithoutResponse.setTitle("N/A", for: .normal)
        }
        self.bleFramework.ble_notify_getData = 0
        let rxQueue: DispatchQueue = DispatchQueue(label: "rx")
        rxQueue.async (){ ()-> Void in
            while self.rxQueueInUse
            {
                if (self.bleFramework.ble_notify_getData == 1)
                {
                    self.bleFramework.ble_notify_getData = 0
                    DispatchQueue.main.async(execute: {
                        if self.stringType.selectedSegmentIndex == 0
                        {
                            self.log.text.append("\(self.FormatDataWithSpace(self.bleFramework.ble_byteArray))\n")
                        }else
                        {
                            if let string = String(bytes: self.bleFramework.ble_byteArray, encoding: .utf8)
                            {
                                self.log.text.append("\(string)\n")
                            }
                        }
                    })
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        rxQueueInUse = false
        super.viewDidDisappear(true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func enableNotify(_ sender: Any) {
        bleFramework.SetNotify(to: bleFramework.peripheralInUse, characteristic: charInUse, enabled: true)
        log.text += "enable notify\n"
    }
    
    @IBAction func disableNotify(_ sender: Any) {
        bleFramework.SetNotify(to: bleFramework.peripheralInUse, characteristic: charInUse, enabled: false)
        log.text += "disable notify\n"
    }
    @IBAction func read(_ sender: Any) {
        bleFramework.ReadData(to: bleFramework.peripheralInUse, characteristic: charInUse)
    }
    @IBAction func write(_ sender: Any) {
        writeCmd = writeField.text!
        WriteData(writeType: .withResponse)
    }
    @IBAction func writeWithoutResponse(_ sender: Any) {
        writeCmd = writeField.text!
        WriteData(writeType: .withoutResponse)
    }
    
    private func WriteData(writeType: CBCharacteristicWriteType)
    {
        self.log.text.append("write: \(writeCmd)\n")
        
        if (stringType.selectedSegmentIndex == 0)
        {
            let bytes = writeCmd.utf8
            var buffer = [UInt8]()
            for i in 0..<bytes.count/2{
                let str = (writeCmd as NSString).substring(with: NSMakeRange(i*2, 2))
                let value = Int(str, radix: 16)
                if value != nil {
                    buffer.append((UInt8)(value!))
                }
            }
            
            if ((bytes.count % 2) > 0){
                let str = (writeCmd as NSString).substring(with: NSMakeRange(bytes.count-1, 1))
                let value = Int(str, radix: 16)
                if value != nil {
                    buffer.append((UInt8)(value!))
                }
            }
            
            let data = NSData(bytes: buffer, length: buffer.count)
            let setCmdQueue: DispatchQueue = DispatchQueue(label: "setCmd")
            setCmdQueue.async (){ ()-> Void in
                if self.bleFramework.WriteData(to: self.bleFramework.peripheralInUse, data as Data, characteristic: self.charInUse, writeType: writeType, waitRx: false)
                {
                    
                }
            }
            
        }else
        {
            let setCmdQueue: DispatchQueue = DispatchQueue(label: "setCmd")
            setCmdQueue.async (){ ()-> Void in
                if self.bleFramework.WriteData(to: self.bleFramework.peripheralInUse, (self.writeCmd.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)))!, characteristic: self.charInUse, writeType: writeType, waitRx: false)
                {
                    
                }
            }
        }
    }
    
    private func FormatDataWithSpace(_ data: [UInt8]) -> String {
        guard data.count != 0 else {
            return ""
        }
        var result = [String]()
        for i in 0..<data.count {
            result.append(String(format:"%02X", data[i]))
        }
        return result.joined(separator: " ")
    }
}
