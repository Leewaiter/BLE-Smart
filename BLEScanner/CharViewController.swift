//
//  CharViewController.swift
//  BLEScanner
//
//  Created by rafael_sw on 2021/4/20.
//

import Foundation
import UIKit
import CoreBluetooth
import BLEFramework

class CharViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    public var bleFramework : BLEFramework!
    public var serviceInUse: CBService!
    private var charTitles: [String] = []
    private var charUUIDs: [String] = []
    private var charSubtitles: [String] = []
    private var chars: [CBCharacteristic] = []
    private var charProperties: [[String]] = []
    private var charInUse: CBCharacteristic!
    private var enabled = false
    public var hasRead: Bool = false
    public var hasWrite: Bool = false
    public var hasWriteWoRes: Bool = false
    public var hasNotify: Bool = false
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue_characteristic_to_operation" {
            let controller = segue.destination as? OperationViewController
            controller?.bleFramework = bleFramework
            controller?.hasRead = hasRead
            controller?.hasWrite = hasWrite
            controller?.hasWriteWoRes = hasWriteWoRes
            controller?.hasNotify = hasNotify
            controller?.charInUse = charInUse
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var index = 0
        for service in bleFramework.peripheralInUse.services! {
            if service != serviceInUse {
                continue
            }
            print("service: \(service.uuid.uuidString)")
            for characteristic in serviceInUse.characteristics! {
                print("characteristic: \(characteristic.uuid.uuidString)")
                charTitles.append("Characteristics(\(index))")
                charUUIDs.append(characteristic.uuid.uuidString)
                charSubtitles.append("Characteristic(\(BLEFramework.GetCharPropertiesString(characteristic: characteristic)))")
                charProperties.append(BLEFramework.GetCharProperties(characteristic: characteristic))
                chars.append(characteristic)
                index += 1
            }
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
        print(charSubtitles[indexPath.row])
        let str = charSubtitles[indexPath.row].components(separatedBy: ",")
        hasRead = false;hasWrite = false;hasWriteWoRes = false;hasNotify = false
        for i in 0..<str.count {
            if str[i].contains("WithoutResponse"){
                hasWriteWoRes = true
            }else if str[i].contains("Write"){
                hasWrite = true
            } else if str[i].contains("Read"){
                hasRead = true
            } else if (str[i].contains("Notify") || str[i].contains("Indicate")){
                hasNotify = true
            }
        }
        charInUse = chars[indexPath.row]
        self.performSegue(withIdentifier: "segue_characteristic_to_operation", sender: nil)
    }
}
