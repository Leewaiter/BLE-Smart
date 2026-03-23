//
//  CharViewController.swift
//  BLEScanner
//
//  Created by rafael_sw on 2021/4/20.
//

import Foundation
import UIKit
import CoreBluetooth

class CharViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    public var peripheral: CBPeripheral!       // 取代 bleFramework
    public var serviceInUse: CBService!
    private var charTitles: [String] = []
    private var charUUIDs: [String] = []
    private var charSubtitles: [String] = []
    private var chars: [CBCharacteristic] = []
    private var charProperties: [[String]] = []
    private var charInUse: CBCharacteristic!
    public var hasRead: Bool = false
    public var hasWrite: Bool = false
    public var hasWriteWoRes: Bool = false
    public var hasNotify: Bool = false
    
    // 取代 BLEFramework.GetCharProperties — 回傳屬性字串陣列
    private static func getCharProperties(characteristic: CBCharacteristic) -> [String] {
        let props = characteristic.properties
        var result: [String] = []
        if props.contains(.read)                { result.append("Read") }
        if props.contains(.write)               { result.append("Write") }
        if props.contains(.writeWithoutResponse){ result.append("WriteWithoutResponse") }
        if props.contains(.notify)              { result.append("Notify") }
        if props.contains(.indicate)            { result.append("Indicate") }
        if props.contains(.broadcast)           { result.append("Broadcast") }
        if props.contains(.authenticatedSignedWrites) { result.append("AuthenticatedSignedWrites") }
        if props.contains(.extendedProperties)  { result.append("ExtendedProperties") }
        return result
    }
    
    // 取代 BLEFramework.GetCharPropertiesString — 回傳逗號分隔字串
    private static func getCharPropertiesString(characteristic: CBCharacteristic) -> String {
        return getCharProperties(characteristic: characteristic).joined(separator: ",")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue_characteristic_to_operation" {
            let controller = segue.destination as? OperationViewController
            controller?.peripheral = peripheral   // 取代 bleFramework
            controller?.hasRead = hasRead
            controller?.hasWrite = hasWrite
            controller?.hasWriteWoRes = hasWriteWoRes
            controller?.hasNotify = hasNotify
            controller?.charInUse = charInUse
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 不需再遍歷所有 services 比對，serviceInUse 已確定
        guard let characteristics = serviceInUse.characteristics else { return }
        
        for (index, characteristic) in characteristics.enumerated() {
            print("characteristic: \(characteristic.uuid.uuidString)")
            charTitles.append("Characteristics(\(index))")
            charUUIDs.append(characteristic.uuid.uuidString)
            charSubtitles.append("Characteristic(\(Self.getCharPropertiesString(characteristic: characteristic)))")
            charProperties.append(Self.getCharProperties(characteristic: characteristic))
            chars.append(characteristic)
        }
    }
}

extension CharViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return charTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CharTableCell", for: indexPath) as! CharTableCell
        cell.charTitle.text = charTitles[indexPath.row]
        cell.charUUID.text = charUUIDs[indexPath.row]
        cell.charSubtitle.text = charSubtitles[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("select cell: \(indexPath.row), char uuid: \(chars[indexPath.row].uuid.uuidString)")
        
        // 直接從 charProperties 讀取，不再 parse 字串
        let props = charProperties[indexPath.row]
        hasRead         = props.contains("Read")
        hasWrite        = props.contains("Write")
        hasWriteWoRes   = props.contains("WriteWithoutResponse")
        hasNotify       = props.contains("Notify") || props.contains("Indicate")
        
        charInUse = chars[indexPath.row]
        self.performSegue(withIdentifier: "segue_characteristic_to_operation", sender: nil)
    }
}
