//
//  Operation.swift
//  BLEScanner
//
//  Created by rafael_sw on 2021/4/20.
//

import Foundation
import UIKit
import CoreBluetooth

class OperationViewController: UIViewController {
    
    @IBOutlet weak var enableNotify: UIButton!
    @IBOutlet weak var disableNotify: UIButton!
    @IBOutlet weak var read: UIButton!
    @IBOutlet weak var write: UIButton!
    @IBOutlet weak var writeWithoutResponse: UIButton!
    @IBOutlet weak var stringType: UISegmentedControl!
    @IBOutlet weak var writeField: UITextField!
    @IBOutlet weak var log: UITextView!
    
    public var peripheral: CBPeripheral!       // 取代 bleFramework
    public var charInUse: CBCharacteristic!
    public var hasRead: Bool = false
    public var hasWrite: Bool = false
    public var hasWriteWoRes: Bool = false
    public var hasNotify: Bool = false
    private var writeCmd = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // delegate 指向自己，接收 BLE 回調
        peripheral.delegate = self
        
        enableNotify.isEnabled = hasNotify
        disableNotify.isEnabled = hasNotify
        read.isEnabled = hasRead
        write.isEnabled = hasWrite
        writeWithoutResponse.isEnabled = hasWriteWoRes
        
        if !hasNotify {
            enableNotify.setTitle("N/A", for: .normal)
            disableNotify.setTitle("N/A", for: .normal)
        }
        if !hasRead    { read.setTitle("N/A", for: .normal) }
        if !hasWrite   { write.setTitle("N/A", for: .normal) }
        if !hasWriteWoRes { writeWithoutResponse.setTitle("N/A", for: .normal) }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func enableNotify(_ sender: Any) {
        peripheral.setNotifyValue(true, for: charInUse)
        log.text += "enable notify\n"
    }
    
    @IBAction func disableNotify(_ sender: Any) {
        peripheral.setNotifyValue(false, for: charInUse)
        log.text += "disable notify\n"
    }
    
    @IBAction func read(_ sender: Any) {
        peripheral.readValue(for: charInUse)
    }
    
    @IBAction func write(_ sender: Any) {
        writeCmd = writeField.text!
        writeData(writeType: .withResponse)
    }
    
    @IBAction func writeWithoutResponse(_ sender: Any) {
        writeCmd = writeField.text!
        writeData(writeType: .withoutResponse)
    }
    
    private func writeData(writeType: CBCharacteristicWriteType) {
        log.text.append("write: \(writeCmd)\n")
        
        let data: Data
        if stringType.selectedSegmentIndex == 0 {
            // Hex 字串轉 Data
            data = hexStringToData(writeCmd)
        } else {
            // UTF-8 字串轉 Data
            data = writeCmd.data(using: .utf8) ?? Data()
        }
        
        guard !data.isEmpty else { return }
        peripheral.writeValue(data, for: charInUse, type: writeType)
    }
    
    private func hexStringToData(_ hex: String) -> Data {
        var buffer = [UInt8]()
        let cleaned = hex.replacingOccurrences(of: " ", with: "")
        var index = cleaned.startIndex
        while index < cleaned.endIndex {
            let nextIndex = cleaned.index(index, offsetBy: 2, limitedBy: cleaned.endIndex) ?? cleaned.endIndex
            if let byte = UInt8(cleaned[index..<nextIndex], radix: 16) {
                buffer.append(byte)
            }
            index = nextIndex
        }
        return Data(buffer)
    }
    
    private func formatDataWithSpace(_ data: Data) -> String {
        guard !data.isEmpty else { return "" }
        return data.map { String(format: "%02X", $0) }.joined(separator: " ")
    }
}

// MARK: - CBPeripheralDelegate
extension OperationViewController: CBPeripheralDelegate {
    
    // 收到 Read / Notify 資料
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        guard characteristic == charInUse,
              let data = characteristic.value else { return }
        
        DispatchQueue.main.async {
            if self.stringType.selectedSegmentIndex == 0 {
                self.log.text.append("\(self.formatDataWithSpace(data))\n")
            } else {
                let string = String(data: data, encoding: .utf8) ?? "(invalid utf8)"
                self.log.text.append("\(string)\n")
            }
        }
    }
    
    // Write with response 完成回調
    func peripheral(_ peripheral: CBPeripheral,
                    didWriteValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                self.log.text.append("write error: \(error.localizedDescription)\n")
            } else {
                self.log.text.append("write success\n")
            }
        }
    }
    
    // Notify 狀態變更回調
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateNotificationStateFor characteristic: CBCharacteristic,
                    error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                self.log.text.append("notify error: \(error.localizedDescription)\n")
            } else {
                self.log.text.append("notify \(characteristic.isNotifying ? "enabled" : "disabled")\n")
            }
        }
    }
}
