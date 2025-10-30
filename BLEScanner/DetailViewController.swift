//
//  ScanViewController.swift
//  BLEScanner
//
//  Created by rafael_sw on 2021/3/30.
//

import Foundation
import UIKit
import CoreBluetooth
import CoreLocation
import BLEFramework


class DetailViewController: UIViewController, UIGestureRecognizerDelegate, CBPeripheralManagerDelegate{
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        self.peripheralManager?.startAdvertising(beaconPeripheralData as? [String: Any])
    }
    
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager?


    @IBOutlet weak var tableView: UITableView!
    private var bleFramework : BLEFramework!
    private var charInUse: CBCharacteristic!
    private var foundPeripherals: [CBPeripheral] = []
    private var deviceStatus: [Bool] = []
    private var deviceConnected: [Bool] = []
    private var deviceRSSI: [String] = []
    private var deviceUUIDs: [String] = []
    private var deviceInUseUUID = ""
    private var binPath = "/fota_bin"
    private var logPath = "/log"
    private var serviceDictionary = [CBService: [CBCharacteristic]]()
    private let greenColor = UIColor(red: 20/255, green: 210/255, blue: 57/255, alpha: 1)

    
    var info: [String] = []
    var peripheralArray: [CBPeripheral] = []
    var id: [String] = []
    var major: [Int] = []
    var minor: [Int] = []
    var status: [Bool] = []
    var index: Int? = nil
    var selectedRows = [IndexPath]()
    var selectId = Int()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bleFramework = BLEFramework()
        print(bleFramework.GetVersion())
        bleFramework.Initialize()
        let iPhoneVersion = PhoneInformation()
        bleFramework.largeMTU = iPhoneVersion.GetDeviceInfo()
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(GroupViewController.longPress(longPressGestureRecognizer:)))
        longPressRecognizer.minimumPressDuration = 1.0 // 1 second press
        longPressRecognizer.delegate = self
        self.view.addGestureRecognizer(longPressRecognizer)
        

        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
   
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    //Cache Document
    func getDocumentsPath(path: String) -> String? {
        let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last as NSString?
        let filePath = docPath?.appendingPathComponent(path);
        return filePath
    }
    
    public func delay(by delayTime: TimeInterval, qosClass: DispatchQoS.QoSClass? = nil,_ closure: @escaping () -> Void) {
        let dispatchQueue = qosClass != nil ? DispatchQueue.global(qos: qosClass!) : .main
        dispatchQueue.asyncAfter(deadline: DispatchTime.now() + delayTime, execute: closure)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       if selectId == 0{
            let recipes = Recipe_Group1.createRecipes()
            return recipes.count
        }else if selectId == 1{
            let recipes = Recipe_Group2.createRecipes()
            return recipes.count
        }else if selectId == 2{
            let recipes = Recipe_Group3.createRecipes()
            return recipes.count
        }else if selectId == 3{
            let recipes = Recipe_Group4.createRecipes()
            return recipes.count
        }else if selectId == 5{
            let recipes = Recipe_Switch1.createRecipes()
            return recipes.count
        }else if selectId == 6{
            let recipes = Recipe_Switch2.createRecipes()
            return recipes.count
        }else if selectId == 7{
            let recipes = Recipe_Switch3.createRecipes()
            return recipes.count
        }else if selectId == 8{
            let recipes = Recipe_Switch4.createRecipes()
            return recipes.count
        }else if selectId == 9{
            let recipes = Recipe_Sensor1.createRecipes()
            return recipes.count
        }else if selectId == 10{
            let recipes = Recipe_Sensor2.createRecipes()
            return recipes.count
        }else if selectId == 11{
            let recipes = Recipe_Sensor3.createRecipes()
            return recipes.count
        }else if selectId == 12{
            let recipes = Recipe_Sensor4.createRecipes()
            return recipes.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTableCell") as? DetailTableCell {
            if selectId == 0{
                let recipes_Group1 = Recipe_Group1.createRecipes()
                let button = UIButton(type: .custom)
                if MyVariables.groupCheckboxArray1[indexPath.row] == true{
                    button.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
                }else{
                    button.setImage(UIImage(systemName: "square"), for: .normal)
                }
                button.setPreferredSymbolConfiguration(.init(scale: UIImage.SymbolScale.large), forImageIn: .normal)
                button.sizeToFit()
                button.tag = indexPath.row
                button.addTarget(self, action: #selector(checkboxClicked), for: .touchUpInside)
                
                cell.configurateTheCell1(recipes_Group1[indexPath.row])
                cell.selectionStyle = .none
                cell.accessoryView = button
            }else if selectId == 1{
                let recipes_Group2 = Recipe_Group2.createRecipes()
                let button = UIButton(type: .custom)
                if MyVariables.groupCheckboxArray2[indexPath.row] == true{
                    button.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
                }else{
                    button.setImage(UIImage(systemName: "square"), for: .normal)
                }
                button.setPreferredSymbolConfiguration(.init(scale: UIImage.SymbolScale.large), forImageIn: .normal)
                button.sizeToFit()
                button.tag = indexPath.row
                button.addTarget(self, action: #selector(checkboxClicked), for: .touchUpInside)
                
                cell.configurateTheCell2(recipes_Group2[indexPath.row])
                cell.selectionStyle = .none
                cell.accessoryView = button
            }else if selectId == 2{
                let recipes_Group3 = Recipe_Group3.createRecipes()
                let button = UIButton(type: .custom)
                if MyVariables.groupCheckboxArray3[indexPath.row] == true{
                    button.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
                }else{
                    button.setImage(UIImage(systemName: "square"), for: .normal)
                }
                button.setPreferredSymbolConfiguration(.init(scale: UIImage.SymbolScale.large), forImageIn: .normal)
                button.sizeToFit()
                button.tag = indexPath.row
                button.addTarget(self, action: #selector(checkboxClicked), for: .touchUpInside)
                
                cell.configurateTheCell3(recipes_Group3[indexPath.row])
                cell.selectionStyle = .none
                cell.accessoryView = button
            }else if selectId == 3{
                let recipes_Group4 = Recipe_Group4.createRecipes()
                let button = UIButton(type: .custom)
                if MyVariables.groupCheckboxArray4[indexPath.row] == true{
                    button.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
                }else{
                    button.setImage(UIImage(systemName: "square"), for: .normal)
                }
                button.setPreferredSymbolConfiguration(.init(scale: UIImage.SymbolScale.large), forImageIn: .normal)
                button.sizeToFit()
                button.tag = indexPath.row
                button.addTarget(self, action: #selector(checkboxClicked), for: .touchUpInside)
                
                cell.configurateTheCell4(recipes_Group4[indexPath.row])
                cell.selectionStyle = .none
                cell.accessoryView = button
            }else if selectId == 5{
                let recipes_Switch1 = Recipe_All.createRecipes()
                let button = UIButton(type: .custom)
                var checkbox = false
                let switchName = MyVariables.switch1.suffix(4).lowercased()
                
                if !MyVariables.switchInformations.isEmpty {
                    for i in 0...MyVariables.switchInformations.count-1{
                        if switchName == MyVariables.switchInformations[i][0][0]{
                            if !MyVariables.switchInformations[i][1].isEmpty {
                                for j in 0...MyVariables.switchInformations[i][1].count-1{
                                    if MyVariables.groupDeviceArrayAll[indexPath.row] == MyVariables.switchInformations[i][1][j]{
                                        checkbox = true
                                    }
                                }
                            }
                        }
                    }
                }
                
                if checkbox == true{
                    button.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
                    MyVariables.switchCheckboxArray1[indexPath.row] = true
                }else{
                    button.setImage(UIImage(systemName: "square"), for: .normal)
                    MyVariables.switchCheckboxArray1[indexPath.row] = false
                }
                
                button.setPreferredSymbolConfiguration(.init(scale: UIImage.SymbolScale.large), forImageIn: .normal)
                button.sizeToFit()
                button.tag = indexPath.row
                button.addTarget(self, action: #selector(checkboxClicked), for: .touchUpInside)
                
 
                cell.configurateTheCellAll(recipes_Switch1[indexPath.row])
                cell.selectionStyle = .none
                cell.accessoryView = button
                
                
            }else if selectId == 6{
                let recipes_Switch2 = Recipe_All.createRecipes()
                let button = UIButton(type: .custom)
                var checkbox = false
                let switchName = MyVariables.switch2.suffix(4).lowercased()
                
                if !MyVariables.switchInformations.isEmpty {
                    for i in 0...MyVariables.switchInformations.count-1{
                        if switchName == MyVariables.switchInformations[i][0][0]{
                            if !MyVariables.switchInformations[i][1].isEmpty {
                                for j in 0...MyVariables.switchInformations[i][1].count-1{
                                    if MyVariables.groupDeviceArrayAll[indexPath.row] == MyVariables.switchInformations[i][1][j]{
                                        print(MyVariables.groupDeviceArrayAll)
                                        print(MyVariables.switchInformations)
                                        print(MyVariables.switchInformations[i][1][j])
                                        checkbox = true
                                    }
                                }
                            }
                        }
                    }
                }
                
                if checkbox == true{
                    button.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
                    MyVariables.switchCheckboxArray2[indexPath.row] = true
                }else{
                    button.setImage(UIImage(systemName: "square"), for: .normal)
                    MyVariables.switchCheckboxArray2[indexPath.row] = false
                }
                
                button.setPreferredSymbolConfiguration(.init(scale: UIImage.SymbolScale.large), forImageIn: .normal)
                button.sizeToFit()
                button.tag = indexPath.row
                button.addTarget(self, action: #selector(checkboxClicked), for: .touchUpInside)
                
 
                cell.configurateTheCellAll(recipes_Switch2[indexPath.row])
                cell.selectionStyle = .none
                cell.accessoryView = button
            }else if selectId == 7{
                let recipes_Switch3 = Recipe_All.createRecipes()
                let button = UIButton(type: .custom)
                var checkbox = false
                let switchName = MyVariables.switch3.suffix(4).lowercased()
                
                if !MyVariables.switchInformations.isEmpty {
                    for i in 0...MyVariables.switchInformations.count-1{
                        if switchName == MyVariables.switchInformations[i][0][0]{
                            if !MyVariables.switchInformations[i][1].isEmpty {
                                for j in 0...MyVariables.switchInformations[i][1].count-1{
                                    if MyVariables.groupDeviceArrayAll[indexPath.row] == MyVariables.switchInformations[i][1][j]{
                                        checkbox = true
                                    }
                                }
                            }
                        }
                    }
                }
                
                if checkbox == true{
                    button.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
                    MyVariables.switchCheckboxArray3[indexPath.row] = true
                }else{
                    button.setImage(UIImage(systemName: "square"), for: .normal)
                    MyVariables.switchCheckboxArray3[indexPath.row] = false
                }
                
                button.setPreferredSymbolConfiguration(.init(scale: UIImage.SymbolScale.large), forImageIn: .normal)
                button.sizeToFit()
                button.tag = indexPath.row
                button.addTarget(self, action: #selector(checkboxClicked), for: .touchUpInside)
                
 
                cell.configurateTheCellAll(recipes_Switch3[indexPath.row])
                cell.selectionStyle = .none
                cell.accessoryView = button
            }else if selectId == 8{
                let recipes_Switch4 = Recipe_All.createRecipes()
                let button = UIButton(type: .custom)
                var checkbox = false
                let switchName = MyVariables.switch4.suffix(4).lowercased()
                
                if !MyVariables.switchInformations.isEmpty {
                    for i in 0...MyVariables.switchInformations.count-1{
                        if switchName == MyVariables.switchInformations[i][0][0]{
                            if !MyVariables.switchInformations[i][1].isEmpty {
                                for j in 0...MyVariables.switchInformations[i][1].count-1{
                                    if MyVariables.groupDeviceArrayAll[indexPath.row] == MyVariables.switchInformations[i][1][j]{
                                        checkbox = true
                                    }
                                }
                            }
                        }
                    }
                }
                
                if checkbox == true{
                    button.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
                    MyVariables.switchCheckboxArray4[indexPath.row] = true
                }else{
                    button.setImage(UIImage(systemName: "square"), for: .normal)
                    MyVariables.switchCheckboxArray4[indexPath.row] = false
                }
                
                button.setPreferredSymbolConfiguration(.init(scale: UIImage.SymbolScale.large), forImageIn: .normal)
                button.sizeToFit()
                button.tag = indexPath.row
                button.addTarget(self, action: #selector(checkboxClicked), for: .touchUpInside)
                
 
                cell.configurateTheCellAll(recipes_Switch4[indexPath.row])
                cell.selectionStyle = .none
                cell.accessoryView = button
            }else if selectId == 9{
                let recipes_Sensor1 = Recipe_All.createRecipes()
                let button = UIButton(type: .custom)
                var checkbox = false
                let sensorName = MyVariables.sensor1.suffix(4).lowercased()
                
                if !MyVariables.sensorInformations.isEmpty {
                    for i in 0...MyVariables.sensorInformations.count-1{
                        if sensorName == MyVariables.sensorInformations[i][0][0]{
                            if !MyVariables.sensorInformations[i][1].isEmpty {
                                for j in 0...MyVariables.sensorInformations[i][1].count-1{
                                    if MyVariables.groupDeviceArrayAll[indexPath.row] == MyVariables.sensorInformations[i][1][j]{
                                        checkbox = true
                                    }
                                }
                            }
                        }
                    }
                }

                if checkbox == true{
                    button.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
                    MyVariables.sensorCheckboxArray1[indexPath.row] = true
                }else{
                    button.setImage(UIImage(systemName: "square"), for: .normal)
                    MyVariables.sensorCheckboxArray1[indexPath.row] = false
                }
                
                button.setPreferredSymbolConfiguration(.init(scale: UIImage.SymbolScale.large), forImageIn: .normal)
                button.sizeToFit()
                button.tag = indexPath.row
                button.addTarget(self, action: #selector(checkboxClicked), for: .touchUpInside)
                
 
                cell.configurateTheCellAll(recipes_Sensor1[indexPath.row])
                cell.selectionStyle = .none
                cell.accessoryView = button
            }else if selectId == 10{
                let recipes_Sensor2 = Recipe_All.createRecipes()
                let button = UIButton(type: .custom)
                var checkbox = false
                let sensorName = MyVariables.sensor2.suffix(4).lowercased()
                
                if !MyVariables.sensorInformations.isEmpty {
                    for i in 0...MyVariables.sensorInformations.count-1{
                        if sensorName == MyVariables.sensorInformations[i][0][0]{
                            if !MyVariables.sensorInformations[i][1].isEmpty {
                                for j in 0...MyVariables.sensorInformations[i][1].count-1{
                                    if MyVariables.groupDeviceArrayAll[indexPath.row] == MyVariables.sensorInformations[i][1][j]{
                                        checkbox = true
                                    }
                                }
                            }
                        }
                    }
                }
                
                if checkbox == true{
                    button.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
                    MyVariables.sensorCheckboxArray2[indexPath.row] = true
                }else{
                    button.setImage(UIImage(systemName: "square"), for: .normal)
                    MyVariables.sensorCheckboxArray2[indexPath.row] = false
                }
                
                button.setPreferredSymbolConfiguration(.init(scale: UIImage.SymbolScale.large), forImageIn: .normal)
                button.sizeToFit()
                button.tag = indexPath.row
                button.addTarget(self, action: #selector(checkboxClicked), for: .touchUpInside)
                
 
                cell.configurateTheCellAll(recipes_Sensor2[indexPath.row])
                cell.selectionStyle = .none
                cell.accessoryView = button
            }else if selectId == 11{
                let recipes_Sensor3 = Recipe_All.createRecipes()
                let button = UIButton(type: .custom)
                var checkbox = false
                let sensorName = MyVariables.sensor3.suffix(4).lowercased()
                
                if !MyVariables.sensorInformations.isEmpty {
                    for i in 0...MyVariables.sensorInformations.count-1{
                        if sensorName == MyVariables.sensorInformations[i][0][0]{
                            if !MyVariables.sensorInformations[i][1].isEmpty {
                                for j in 0...MyVariables.sensorInformations[i][1].count-1{
                                    if MyVariables.groupDeviceArrayAll[indexPath.row] == MyVariables.sensorInformations[i][1][j]{
                                        checkbox = true
                                    }
                                }
                            }
                        }
                    }
                }
                
                if checkbox == true{
                    button.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
                    MyVariables.sensorCheckboxArray3[indexPath.row] = true
                }else{
                    button.setImage(UIImage(systemName: "square"), for: .normal)
                    MyVariables.sensorCheckboxArray3[indexPath.row] = false
                }
                
                button.setPreferredSymbolConfiguration(.init(scale: UIImage.SymbolScale.large), forImageIn: .normal)
                button.sizeToFit()
                button.tag = indexPath.row
                button.addTarget(self, action: #selector(checkboxClicked), for: .touchUpInside)
                
 
                cell.configurateTheCellAll(recipes_Sensor3[indexPath.row])
                cell.selectionStyle = .none
                cell.accessoryView = button
            }else if selectId == 12{
                let recipes_Sensor4 = Recipe_All.createRecipes()
                let button = UIButton(type: .custom)
                var checkbox = false
                let sensorName = MyVariables.sensor4.suffix(4).lowercased()
                
                if !MyVariables.sensorInformations.isEmpty {
                    for i in 0...MyVariables.sensorInformations.count-1{
                        if sensorName == MyVariables.sensorInformations[i][0][0]{
                            if !MyVariables.sensorInformations[i][1].isEmpty {
                                for j in 0...MyVariables.sensorInformations[i][1].count-1{
                                    if MyVariables.groupDeviceArrayAll[indexPath.row] == MyVariables.sensorInformations[i][1][j]{
                                        checkbox = true
                                    }
                                }
                            }
                        }
                    }
                }
                
                if checkbox == true{
                    button.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
                    MyVariables.sensorCheckboxArray4[indexPath.row] = true
                }else{
                    button.setImage(UIImage(systemName: "square"), for: .normal)
                    MyVariables.sensorCheckboxArray4[indexPath.row] = false
                }
                
                button.setPreferredSymbolConfiguration(.init(scale: UIImage.SymbolScale.large), forImageIn: .normal)
                button.sizeToFit()
                button.tag = indexPath.row
                button.addTarget(self, action: #selector(checkboxClicked), for: .touchUpInside)
                
 
                cell.configurateTheCellAll(recipes_Sensor4[indexPath.row])
                cell.selectionStyle = .none
                cell.accessoryView = button
            }

            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        if selectId == 0{
            let cutString = MyVariables.groupDeviceArray1[indexPath.row]
            let name = String(cutString.suffix(from: cutString.index(cutString.endIndex, offsetBy: -4)))
            MyVariables.groupCheckboxArray1[indexPath.row] = !MyVariables.groupCheckboxArray1[indexPath.row]
            if MyVariables.groupCheckboxArray1[indexPath.row] == true{
                let uuid = UUID(uuidString: "52455454-4c00-0000-0000-00000001a000")!
                let localBeaconMajor: CLBeaconMajorValue = CLBeaconMajorValue(Int(name, radix: 16)!)
                let localBeaconMinor: CLBeaconMinorValue = 0
                localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
            }
            else{
                let uuid = UUID(uuidString: "52455454-4c00-0000-0000-00000001c000")!
                let localBeaconMajor: CLBeaconMajorValue = CLBeaconMajorValue(Int(name, radix: 16)!)
                let localBeaconMinor: CLBeaconMinorValue = 0
                localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
            }

            peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
            delay(by: 1){
                self.peripheralManager?.stopAdvertising()
            }
        }else if selectId == 1{
            let cutString = MyVariables.groupDeviceArray2[indexPath.row]
            let name = String(cutString.suffix(from: cutString.index(cutString.endIndex, offsetBy: -4)))
            MyVariables.groupCheckboxArray2[indexPath.row] = !MyVariables.groupCheckboxArray2[indexPath.row]
            if MyVariables.groupCheckboxArray2[indexPath.row] == true{
                let uuid = UUID(uuidString: "52455454-4c00-0000-0000-00000002a000")!
                let localBeaconMajor: CLBeaconMajorValue = CLBeaconMajorValue(Int(name, radix: 16)!)
                let localBeaconMinor: CLBeaconMinorValue = 0
                localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
            }
            else{
                let uuid = UUID(uuidString: "52455454-4c00-0000-0000-00000002c000")!
                let localBeaconMajor: CLBeaconMajorValue = CLBeaconMajorValue(Int(name, radix: 16)!)
                let localBeaconMinor: CLBeaconMinorValue = 0
                localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
            }

            peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
            delay(by: 1){
                self.peripheralManager?.stopAdvertising()
            }
            
        }else if selectId == 2{
            let cutString = MyVariables.groupDeviceArray3[indexPath.row]
            let name = String(cutString.suffix(from: cutString.index(cutString.endIndex, offsetBy: -4)))
            MyVariables.groupCheckboxArray3[indexPath.row] = !MyVariables.groupCheckboxArray3[indexPath.row]
            if MyVariables.groupCheckboxArray3[indexPath.row] == true{
                let uuid = UUID(uuidString: "52455454-4c00-0000-0000-00000004a000")!
                let localBeaconMajor: CLBeaconMajorValue = CLBeaconMajorValue(Int(name, radix: 16)!)
                let localBeaconMinor: CLBeaconMinorValue = 0
                localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
            }
            else{
                let uuid = UUID(uuidString: "52455454-4c00-0000-0000-00000004c000")!
                let localBeaconMajor: CLBeaconMajorValue = CLBeaconMajorValue(Int(name, radix: 16)!)
                let localBeaconMinor: CLBeaconMinorValue = 0
                localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
            }

            peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
            delay(by: 1){
                self.peripheralManager?.stopAdvertising()
            }
            
        }else if selectId == 3{
            let cutString = MyVariables.groupDeviceArray4[indexPath.row]
            let name = String(cutString.suffix(from: cutString.index(cutString.endIndex, offsetBy: -4)))
            MyVariables.groupCheckboxArray4[indexPath.row] = !MyVariables.groupCheckboxArray4[indexPath.row]
            if MyVariables.groupCheckboxArray4[indexPath.row] == true{
                let uuid = UUID(uuidString: "52455454-4c00-0000-0000-00000008a000")!
                let localBeaconMajor: CLBeaconMajorValue = CLBeaconMajorValue(Int(name, radix: 16)!)
                let localBeaconMinor: CLBeaconMinorValue = 0
                localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
            }
            else{
                let uuid = UUID(uuidString: "52455454-4c00-0000-0000-00000008c000")!
                let localBeaconMajor: CLBeaconMajorValue = CLBeaconMajorValue(Int(name, radix: 16)!)
                let localBeaconMinor: CLBeaconMinorValue = 0
                localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
            }

            peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
            delay(by: 1){
                self.peripheralManager?.stopAdvertising()
            }
 
        }else if selectId == 5{
            if MyVariables.switch1 != "None"{
                let cutString = MyVariables.switchDeviceArray1[indexPath.row]
                let name = String(cutString.suffix(from: cutString.index(cutString.endIndex, offsetBy: -4)))
                
                MyVariables.switchCheckboxArray1[indexPath.row] = !MyVariables.switchCheckboxArray1[indexPath.row]
                if MyVariables.switchCheckboxArray1[indexPath.row] == true{
                    
                    var uuid: UUID
                    if MyVariables.switch1.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch1.suffix(4)) + "-0000-fefefefe0000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch1.suffix(4)) + "-0100-fefefefe0000")!
                    }
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.switchInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.switch1.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].append("RELAY_SW_" + name)
                            print("在找到的陣列後面新增了 \("RELAY_SW_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.switch1.suffix(4)).lowercased()],["RELAY_SW_" + name]])
                            print("創建陣列並新增了 \("RELAY_SW_" + name)")
                        }

                    }else{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].append("LIGHT_" + name)
                            print("在找到的陣列後面新增了 \("LIGHT_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.switch1.suffix(4)).lowercased()],["LIGHT_" + name]])
                            print("創建陣列並新增了 \("LIGHT_" + name)")
                        }
                        
                    }
                    
                }else{
                    
                    var uuid: UUID
                    if MyVariables.switch1.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch1.suffix(4)) + "-0000-efefefef0000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch1.suffix(4)) + "-0100-efefefef0000")!
                    }
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.switchInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.switch1.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            delay(by: 1) {
                                MyVariables.switchInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 RELAY_SW_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                    }else{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            delay(by: 1) {
                                MyVariables.switchInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 LIGHT_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                    }
                    
                }
                
                peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                delay(by: 1){
                    self.peripheralManager?.stopAdvertising()
                }
            }
 
        }else if selectId == 6{
            if MyVariables.switch2 != "None"{
                let cutString = MyVariables.switchDeviceArray2[indexPath.row]
                let name = String(cutString.suffix(from: cutString.index(cutString.endIndex, offsetBy: -4)))
                
                MyVariables.switchCheckboxArray2[indexPath.row] = !MyVariables.switchCheckboxArray2[indexPath.row]
                if MyVariables.switchCheckboxArray2[indexPath.row] == true{
                    
                    var uuid: UUID
                    if MyVariables.switch2.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch2.suffix(4)) + "-0000-fefefefe0000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch2.suffix(4)) + "-0100-fefefefe0000")!
                    }
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0

                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.switchInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.switch2.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].append("RELAY_SW_" + name)
                            print("在找到的陣列後面新增了 \("RELAY_SW_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.switch2.suffix(4)).lowercased()],["RELAY_SW_" + name]])
                            print("創建陣列並新增了 \("RELAY_SW_" + name)")
                        }
                    }else{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].append("LIGHT_" + name)
                            print("在找到的陣列後面新增了 \("LIGHT_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.switch2.suffix(4)).lowercased()],["LIGHT_" + name]])
                            print("創建陣列並新增了 \("LIGHT_" + name)")
                        }
                    }
                    
                }else{

                    var uuid: UUID
                    if MyVariables.switch2.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch2.suffix(4)) + "-0000-efefefef0000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch2.suffix(4)) + "-0100-efefefef0000")!
                    }
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.switchInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.switch2.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            delay(by: 1) {
                                MyVariables.switchInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 RELAY_SW_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                    }else{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            delay(by: 1) {
                                MyVariables.switchInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 LIGHT_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                    }
                    
                }
                
                peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                delay(by: 1){
                    self.peripheralManager?.stopAdvertising()
                }
            }
 
        }else if selectId == 7{
            if MyVariables.switch3 != "None"{
                let cutString = MyVariables.switchDeviceArray3[indexPath.row]
                let name = String(cutString.suffix(from: cutString.index(cutString.endIndex, offsetBy: -4)))
                
                MyVariables.switchCheckboxArray3[indexPath.row] = !MyVariables.switchCheckboxArray3[indexPath.row]
                if MyVariables.switchCheckboxArray3[indexPath.row] == true{
                    
                    var uuid: UUID
                    if MyVariables.switch3.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch3.suffix(4)) + "-0000-fefefefe0000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch3.suffix(4)) + "-0100-fefefefe0000")!
                    }
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.switchInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.switch3.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].append("RELAY_SW_" + name)
                            print("在找到的陣列後面新增了 \("RELAY_SW_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.switch3.suffix(4)).lowercased()],["RELAY_SW_" + name]])
                            print("創建陣列並新增了 \("RELAY_SW_" + name)")
                        }
                    }else{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].append("LIGHT_" + name)
                            print("在找到的陣列後面新增了 \("LIGHT_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.switch3.suffix(4)).lowercased()],["LIGHT_" + name]])
                            print("創建陣列並新增了 \("LIGHT_" + name)")
                        }
                    }
                    
                }else{
                    
                    var uuid: UUID
                    if MyVariables.switch3.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch3.suffix(4)) + "-0000-efefefef0000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch3.suffix(4)) + "-0100-efefefef0000")!
                    }
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.switchInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.switch3.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            delay(by: 1) {
                                MyVariables.switchInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 RELAY_SW_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                    }else{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            delay(by: 1) {
                                MyVariables.switchInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 LIGHT_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                    }
                    
                }
                
                peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                delay(by: 1){
                    self.peripheralManager?.stopAdvertising()
                }
            }
 
        }else if selectId == 8{
            if MyVariables.switch4 != "None"{
                let cutString = MyVariables.switchDeviceArray4[indexPath.row]
                let name = String(cutString.suffix(from: cutString.index(cutString.endIndex, offsetBy: -4)))
                
                MyVariables.switchCheckboxArray4[indexPath.row] = !MyVariables.switchCheckboxArray4[indexPath.row]
                if MyVariables.switchCheckboxArray4[indexPath.row] == true{
                    
                    var uuid: UUID
                    if MyVariables.switch4.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch4.suffix(4)) + "-0000-fefefefe0000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch4.suffix(4)) + "-0100-fefefefe0000")!
                    }
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.switchInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.switch4.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].append("RELAY_SW_" + name)
                            print("在找到的陣列後面新增了 \("RELAY_SW_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.switch4.suffix(4)).lowercased()],["RELAY_SW_" + name]])
                            print("創建陣列並新增了 \("RELAY_SW_" + name)")
                        }
                    }else{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].append("LIGHT_" + name)
                            print("在找到的陣列後面新增了 \("LIGHT_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.switch4.suffix(4)).lowercased()],["LIGHT_" + name]])
                            print("創建陣列並新增了 \("LIGHT_" + name)")
                        }
                    }
                }else{
                    
                    var uuid: UUID
                    if MyVariables.switch4.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch4.suffix(4)) + "-0000-efefefef0000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch4.suffix(4)) + "-0100-efefefef0000")!
                    }
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.switchInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.switch4.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            delay(by: 1) {
                                MyVariables.switchInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 RELAY_SW_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                    }else{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            delay(by: 1) {
                                MyVariables.switchInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 LIGHT_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                    }
                }
                
                peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                delay(by: 1){
                    self.peripheralManager?.stopAdvertising()
                }
            }
            
        }else if selectId == 9{
            if MyVariables.sensor1 != "None"{
                let cutString = MyVariables.sensorDeviceArray1[indexPath.row]
                let name = String(cutString.suffix(from: cutString.index(cutString.endIndex, offsetBy: -4)))
                
                MyVariables.sensorCheckboxArray1[indexPath.row] = !MyVariables.sensorCheckboxArray1[indexPath.row]
                if MyVariables.sensorCheckboxArray1[indexPath.row] == true{
                    let uuid = UUID(uuidString: "4D515454-4C" + String(MyVariables.sensor1.suffix(4).prefix(2)) + "-" + String(MyVariables.sensor1.suffix(2)) + "AC-ACAC-ACACACACACAC")!
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0

                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.sensorInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.sensor1.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].append("RELAY_SW_" + name)
                            print("在找到的陣列後面新增了 \("RELAY_SW_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.sensor1.suffix(4)).lowercased()],["RELAY_SW_" + name]])
                            print("創建陣列並新增了 \("RELAY_SW_" + name)")
                        }
                    }else{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].append("LIGHT_" + name)
                            print("在找到的陣列後面新增了 \("LIGHT_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.sensor1.suffix(4)).lowercased()],["LIGHT_" + name]])
                            print("創建陣列並新增了 \("LIGHT_" + name)")
                        }
                    }
                    
                }else{
                    let uuid = UUID(uuidString: "4D515454-4C" + String(MyVariables.sensor1.suffix(4).prefix(2)) + "-" + String(MyVariables.sensor1.suffix(2)) + "AD-ADAD-ADADADADADAD")!
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.sensorInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.sensor1.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            delay(by: 1) {
                                MyVariables.sensorInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 RELAY_SW_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                    }else{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            delay(by: 1) {
                                MyVariables.sensorInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 LIGHT_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                    }
                }
                
                peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                delay(by: 1){
                    self.peripheralManager?.stopAdvertising()
                }
            }
 
        }else if selectId == 10{
            if MyVariables.sensor2 != "None"{
                let cutString = MyVariables.sensorDeviceArray2[indexPath.row]
                let name = String(cutString.suffix(from: cutString.index(cutString.endIndex, offsetBy: -4)))
                
                MyVariables.sensorCheckboxArray2[indexPath.row] = !MyVariables.sensorCheckboxArray2[indexPath.row]
                if MyVariables.sensorCheckboxArray2[indexPath.row] == true{
                    let uuid = UUID(uuidString: "4D515454-4C" + String(MyVariables.sensor2.suffix(4).prefix(2)) + "-" + String(MyVariables.sensor2.suffix(2)) + "AC-ACAC-ACACACACACAC")!
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0
                  
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.sensorInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.sensor2.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].append("RELAY_SW_" + name)
                            print("在找到的陣列後面新增了 \("RELAY_SW_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.sensor2.suffix(4)).lowercased()],["RELAY_SW_" + name]])
                            print("創建陣列並新增了 \("RELAY_SW_" + name)")
                        }
                    }else{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].append("LIGHT_" + name)
                            print("在找到的陣列後面新增了 \("LIGHT_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.sensor2.suffix(4)).lowercased()],["LIGHT_" + name]])
                            print("創建陣列並新增了 \("LIGHT_" + name)")
                        }
                    }
                }else{
                    let uuid = UUID(uuidString: "4D515454-4C" + String(MyVariables.sensor2.suffix(4).prefix(2)) + "-" + String(MyVariables.sensor2.suffix(2)) + "AD-ADAD-ADADADADADAD")!
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0
      
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.sensorInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.sensor2.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            delay(by: 1) {
                                MyVariables.sensorInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 RELAY_SW_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                        
                    }else{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            delay(by: 1) {
                                MyVariables.sensorInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 LIGHT_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                    }
                }
                
                peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                delay(by: 1){
                    self.peripheralManager?.stopAdvertising()
                }
            }
 
        }else if selectId == 11{
            if MyVariables.sensor3 != "None"{
                let cutString = MyVariables.sensorDeviceArray3[indexPath.row]
                let name = String(cutString.suffix(from: cutString.index(cutString.endIndex, offsetBy: -4)))
                
                MyVariables.sensorCheckboxArray3[indexPath.row] = !MyVariables.sensorCheckboxArray3[indexPath.row]
                if MyVariables.sensorCheckboxArray3[indexPath.row] == true{
                    let uuid = UUID(uuidString: "4D515454-4C" + String(MyVariables.sensor3.suffix(4).prefix(2)) + "-" + String(MyVariables.sensor3.suffix(2)) + "AC-ACAC-ACACACACACAC")!
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.sensorInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.sensor3.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].append("RELAY_SW_" + name)
                            print("在找到的陣列後面新增了 \("RELAY_SW_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.sensor3.suffix(4)).lowercased()],["RELAY_SW_" + name]])
                            print("創建陣列並新增了 \("RELAY_SW_" + name)")
                        }
                    }else{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].append("LIGHT_" + name)
                            print("在找到的陣列後面新增了 \("LIGHT_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.sensor3.suffix(4)).lowercased()],["LIGHT_" + name]])
                            print("創建陣列並新增了 \("LIGHT_" + name)")
                        }
                    }
                }else{
                    let uuid = UUID(uuidString: "4D515454-4C" + String(MyVariables.sensor3.suffix(4).prefix(2)) + "-" + String(MyVariables.sensor3.suffix(2)) + "AD-ADAD-ADADADADADAD")!
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0

                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.sensorInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.sensor3.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            delay(by: 1) {
                                MyVariables.sensorInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 RELAY_SW_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                    }else{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            delay(by: 1) {
                                MyVariables.sensorInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 LIGHT_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                    }
                }
                
                peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                delay(by: 1){
                    self.peripheralManager?.stopAdvertising()
                }
            }
 
        }else if selectId == 12{
            if MyVariables.sensor4 != "None"{
                let cutString = MyVariables.sensorDeviceArray4[indexPath.row]
                let name = String(cutString.suffix(from: cutString.index(cutString.endIndex, offsetBy: -4)))
                
                MyVariables.sensorCheckboxArray4[indexPath.row] = !MyVariables.sensorCheckboxArray4[indexPath.row]
                if MyVariables.sensorCheckboxArray4[indexPath.row] == true{
                    let uuid = UUID(uuidString: "4D515454-4C" + String(MyVariables.sensor4.suffix(4).prefix(2)) + "-" + String(MyVariables.sensor4.suffix(2)) + "AC-ACAC-ACACACACACAC")!
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.sensorInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.sensor4.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].append("RELAY_SW_" + name)
                            print("在找到的陣列後面新增了 \("RELAY_SW_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.sensor4.suffix(4)).lowercased()],["RELAY_SW_" + name]])
                            print("創建陣列並新增了 \("RELAY_SW_" + name)")
                        }
                    }else{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].append("LIGHT_" + name)
                            print("在找到的陣列後面新增了 \("LIGHT_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.sensor4.suffix(4)).lowercased()],["LIGHT_" + name]])
                            print("創建陣列並新增了 \("LIGHT_" + name)")
                        }
                    }
                }else{
                    let uuid = UUID(uuidString: "4D515454-4C" + String(MyVariables.sensor4.suffix(4).prefix(2)) + "-" + String(MyVariables.sensor4.suffix(2)) + "AD-ADAD-ADADADADADAD")!
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.sensorInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.sensor4.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            delay(by: 1) {
                                MyVariables.sensorInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 RELAY_SW_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                    }else{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            delay(by: 1) {
                                MyVariables.sensorInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 LIGHT_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                    }
                }
                
                peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                delay(by: 1){
                    self.peripheralManager?.stopAdvertising()
                }
            }
 
        }

        tableView.reloadData()
    }
    
    @objc func checkboxClicked(_ sender: UIButton) {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        if selectId == 0{
            let cutString = MyVariables.groupDeviceArray1[sender.tag]
            let name = String(cutString.suffix(from: cutString.index(cutString.endIndex, offsetBy: -4)))
            MyVariables.groupCheckboxArray1[sender.tag] = !MyVariables.groupCheckboxArray1[sender.tag]
            if MyVariables.groupCheckboxArray1[sender.tag] == true{
                let uuid = UUID(uuidString: "52455454-4c00-0000-0000-00000001a000")!
                let localBeaconMajor: CLBeaconMajorValue = CLBeaconMajorValue(Int(name, radix: 16)!)
                let localBeaconMinor: CLBeaconMinorValue = 0
                localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
            }
            else{
                let uuid = UUID(uuidString: "52455454-4c00-0000-0000-00000001c000")!
                let localBeaconMajor: CLBeaconMajorValue = CLBeaconMajorValue(Int(name, radix: 16)!)
                let localBeaconMinor: CLBeaconMinorValue = 0
                localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
            }

            peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
            delay(by: 1){
                self.peripheralManager?.stopAdvertising()
            }
        }else if selectId == 1{
            let cutString = MyVariables.groupDeviceArray2[sender.tag]
            let name = String(cutString.suffix(from: cutString.index(cutString.endIndex, offsetBy: -4)))
            MyVariables.groupCheckboxArray2[sender.tag] = !MyVariables.groupCheckboxArray2[sender.tag]
            if MyVariables.groupCheckboxArray2[sender.tag] == true{
                let uuid = UUID(uuidString: "52455454-4c00-0000-0000-00000002a000")!
                let localBeaconMajor: CLBeaconMajorValue = CLBeaconMajorValue(Int(name, radix: 16)!)
                let localBeaconMinor: CLBeaconMinorValue = 0
                localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
            }
            else{
                let uuid = UUID(uuidString: "52455454-4c00-0000-0000-00000002c000")!
                let localBeaconMajor: CLBeaconMajorValue = CLBeaconMajorValue(Int(name, radix: 16)!)
                let localBeaconMinor: CLBeaconMinorValue = 0
                localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
            }

            peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
            delay(by: 1){
                self.peripheralManager?.stopAdvertising()
            }
            
        }else if selectId == 2{
            let cutString = MyVariables.groupDeviceArray3[sender.tag]
            let name = String(cutString.suffix(from: cutString.index(cutString.endIndex, offsetBy: -4)))
            MyVariables.groupCheckboxArray3[sender.tag] = !MyVariables.groupCheckboxArray3[sender.tag]
            if MyVariables.groupCheckboxArray3[sender.tag] == true{
                let uuid = UUID(uuidString: "52455454-4c00-0000-0000-00000004a000")!
                let localBeaconMajor: CLBeaconMajorValue = CLBeaconMajorValue(Int(name, radix: 16)!)
                let localBeaconMinor: CLBeaconMinorValue = 0
                localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
            }
            else{
                let uuid = UUID(uuidString: "52455454-4c00-0000-0000-00000004c000")!
                let localBeaconMajor: CLBeaconMajorValue = CLBeaconMajorValue(Int(name, radix: 16)!)
                let localBeaconMinor: CLBeaconMinorValue = 0
                localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
            }

            peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
            delay(by: 1){
                self.peripheralManager?.stopAdvertising()
            }
            
        }else if selectId == 3{
            let cutString = MyVariables.groupDeviceArray4[sender.tag]
            let name = String(cutString.suffix(from: cutString.index(cutString.endIndex, offsetBy: -4)))
            MyVariables.groupCheckboxArray4[sender.tag] = !MyVariables.groupCheckboxArray4[sender.tag]
            if MyVariables.groupCheckboxArray4[sender.tag] == true{
                let uuid = UUID(uuidString: "52455454-4c00-0000-0000-00000008a000")!
                let localBeaconMajor: CLBeaconMajorValue = CLBeaconMajorValue(Int(name, radix: 16)!)
                let localBeaconMinor: CLBeaconMinorValue = 0
                localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
            }
            else{
                let uuid = UUID(uuidString: "52455454-4c00-0000-0000-00000008c000")!
                let localBeaconMajor: CLBeaconMajorValue = CLBeaconMajorValue(Int(name, radix: 16)!)
                let localBeaconMinor: CLBeaconMinorValue = 0
                localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
            }

            peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
            delay(by: 1){
                self.peripheralManager?.stopAdvertising()
            }
 
        }else if selectId == 5{
            if MyVariables.switch1 != "None"{
                let cutString = MyVariables.switchDeviceArray1[sender.tag]
                let name = String(cutString.suffix(from: cutString.index(cutString.endIndex, offsetBy: -4)))
                
                MyVariables.switchCheckboxArray1[sender.tag] = !MyVariables.switchCheckboxArray1[sender.tag]
                if MyVariables.switchCheckboxArray1[sender.tag] == true{
                    var uuid: UUID
                    if MyVariables.switch1.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch1.suffix(4)) + "-0000-fefefefe0000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch1.suffix(4)) + "-0100-fefefefe0000")!
                    }
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.switchInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.switch1.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].append("RELAY_SW_" + name)
                            print("在找到的陣列後面新增了 \("RELAY_SW_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.switch1.suffix(4)).lowercased()],["RELAY_SW_" + name]])
                            print("創建陣列並新增了 \("RELAY_SW_" + name)")
                        }

                    }else{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].append("LIGHT_" + name)
                            print("在找到的陣列後面新增了 \("LIGHT_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.switch1.suffix(4)).lowercased()],["LIGHT_" + name]])
                            print("創建陣列並新增了 \("LIGHT_" + name)")
                        }
                        
                    }
                    
                }else{
                    var uuid: UUID
                    if MyVariables.switch1.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch1.suffix(4)) + "-0000-efefefef0000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch1.suffix(4)) + "-0100-efefefef0000")!
                    }
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.switchInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.switch1.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            delay(by: 1) {
                                MyVariables.switchInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 RELAY_SW_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                    }else{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            delay(by: 1) {
                                MyVariables.switchInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 LIGHT_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                    }
                    
                }
                
                peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                delay(by: 1){
                    self.peripheralManager?.stopAdvertising()
                }
            }
 
        }else if selectId == 6{
            if MyVariables.switch2 != "None"{
                let cutString = MyVariables.switchDeviceArray2[sender.tag]
                let name = String(cutString.suffix(from: cutString.index(cutString.endIndex, offsetBy: -4)))
                
                MyVariables.switchCheckboxArray2[sender.tag] = !MyVariables.switchCheckboxArray2[sender.tag]
                if MyVariables.switchCheckboxArray2[sender.tag] == true{
                    var uuid: UUID
                    if MyVariables.switch2.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch2.suffix(4)) + "-0000-fefefefe0000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch2.suffix(4)) + "-0100-fefefefe0000")!
                    }
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0

                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.switchInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.switch2.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].append("RELAY_SW_" + name)
                            print("在找到的陣列後面新增了 \("RELAY_SW_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.switch2.suffix(4)).lowercased()],["RELAY_SW_" + name]])
                            print("創建陣列並新增了 \("RELAY_SW_" + name)")
                        }
                    }else{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].append("LIGHT_" + name)
                            print("在找到的陣列後面新增了 \("LIGHT_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.switch2.suffix(4)).lowercased()],["LIGHT_" + name]])
                            print("創建陣列並新增了 \("LIGHT_" + name)")
                        }
                    }
                    
                }else{
                    var uuid: UUID
                    if MyVariables.switch2.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch2.suffix(4)) + "-0000-efefefef0000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch2.suffix(4)) + "-0100-efefefef0000")!
                    }
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.switchInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.switch2.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            delay(by: 1) {
                                MyVariables.switchInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 RELAY_SW_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                    }else{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            delay(by: 1) {
                                MyVariables.switchInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 LIGHT_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                    }
                    
                }
                
                peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                delay(by: 1){
                    self.peripheralManager?.stopAdvertising()
                }
            }
 
        }else if selectId == 7{
            if MyVariables.switch3 != "None"{
                let cutString = MyVariables.switchDeviceArray3[sender.tag]
                let name = String(cutString.suffix(from: cutString.index(cutString.endIndex, offsetBy: -4)))
                
                MyVariables.switchCheckboxArray3[sender.tag] = !MyVariables.switchCheckboxArray3[sender.tag]
                if MyVariables.switchCheckboxArray3[sender.tag] == true{
                    var uuid: UUID
                    if MyVariables.switch3.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch3.suffix(4)) + "-0000-fefefefe0000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch3.suffix(4)) + "-0100-fefefefe0000")!
                    }
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.switchInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.switch3.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].append("RELAY_SW_" + name)
                            print("在找到的陣列後面新增了 \("RELAY_SW_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.switch3.suffix(4)).lowercased()],["RELAY_SW_" + name]])
                            print("創建陣列並新增了 \("RELAY_SW_" + name)")
                        }
                    }else{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].append("LIGHT_" + name)
                            print("在找到的陣列後面新增了 \("LIGHT_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.switch3.suffix(4)).lowercased()],["LIGHT_" + name]])
                            print("創建陣列並新增了 \("LIGHT_" + name)")
                        }
                    }
                    
                }else{
                    var uuid: UUID
                    if MyVariables.switch3.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch3.suffix(4)) + "-0000-efefefef0000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch3.suffix(4)) + "-0100-efefefef0000")!
                    }
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.switchInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.switch3.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            delay(by: 1) {
                                MyVariables.switchInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 RELAY_SW_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                    }else{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            delay(by: 1) {
                                MyVariables.switchInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 LIGHT_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                    }
                    
                }
                
                peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                delay(by: 1){
                    self.peripheralManager?.stopAdvertising()
                }
            }
 
        }else if selectId == 8{
            if MyVariables.switch4 != "None"{
                let cutString = MyVariables.switchDeviceArray4[sender.tag]
                let name = String(cutString.suffix(from: cutString.index(cutString.endIndex, offsetBy: -4)))
                
                MyVariables.switchCheckboxArray4[sender.tag] = !MyVariables.switchCheckboxArray4[sender.tag]
                if MyVariables.switchCheckboxArray4[sender.tag] == true{
                    var uuid: UUID
                    if MyVariables.switch4.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch4.suffix(4)) + "-0000-fefefefe0000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch4.suffix(4)) + "-0100-fefefefe0000")!
                    }
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.switchInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.switch4.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].append("RELAY_SW_" + name)
                            print("在找到的陣列後面新增了 \("RELAY_SW_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.switch4.suffix(4)).lowercased()],["RELAY_SW_" + name]])
                            print("創建陣列並新增了 \("RELAY_SW_" + name)")
                        }
                    }else{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].append("LIGHT_" + name)
                            print("在找到的陣列後面新增了 \("LIGHT_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.switch4.suffix(4)).lowercased()],["LIGHT_" + name]])
                            print("創建陣列並新增了 \("LIGHT_" + name)")
                        }
                    }
                }else{
                    var uuid: UUID
                    if MyVariables.switch4.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch4.suffix(4)) + "-0000-efefefef0000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch4.suffix(4)) + "-0100-efefefef0000")!
                    }
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.switchInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.switch4.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            delay(by: 1) {
                                MyVariables.switchInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 RELAY_SW_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                    }else{
                        if let index = foundIndex {
                            MyVariables.switchInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            delay(by: 1) {
                                MyVariables.switchInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 LIGHT_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                    }
                }
                
                peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                delay(by: 1){
                    self.peripheralManager?.stopAdvertising()
                }
            }
            
        }else if selectId == 9{
            if MyVariables.sensor1 != "None"{
                let cutString = MyVariables.sensorDeviceArray1[sender.tag]
                let name = String(cutString.suffix(from: cutString.index(cutString.endIndex, offsetBy: -4)))
                
                MyVariables.sensorCheckboxArray1[sender.tag] = !MyVariables.sensorCheckboxArray1[sender.tag]
                if MyVariables.sensorCheckboxArray1[sender.tag] == true{
                    let uuid = UUID(uuidString: "4D515454-4C" + String(MyVariables.sensor1.suffix(4).prefix(2)) + "-" + String(MyVariables.sensor1.suffix(2)) + "AC-ACAC-ACACACACACAC")!
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0

                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.sensorInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.sensor1.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].append("RELAY_SW_" + name)
                            print("在找到的陣列後面新增了 \("RELAY_SW_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.sensor1.suffix(4)).lowercased()],["RELAY_SW_" + name]])
                            print("創建陣列並新增了 \("RELAY_SW_" + name)")
                        }
                    }else{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].append("LIGHT_" + name)
                            print("在找到的陣列後面新增了 \("LIGHT_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.sensor1.suffix(4)).lowercased()],["LIGHT_" + name]])
                            print("創建陣列並新增了 \("LIGHT_" + name)")
                        }
                    }
                    
                }else{
                    let uuid = UUID(uuidString: "4D515454-4C" + String(MyVariables.sensor1.suffix(4).prefix(2)) + "-" + String(MyVariables.sensor1.suffix(2)) + "AD-ADAD-ADADADADADAD")!
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.sensorInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.sensor1.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            delay(by: 1) {
                                MyVariables.sensorInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 RELAY_SW_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                    }else{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            delay(by: 1) {
                                MyVariables.sensorInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 LIGHT_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                    }
                }
                
                peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                delay(by: 1){
                    self.peripheralManager?.stopAdvertising()
                }
            }
 
        }else if selectId == 10{
            if MyVariables.sensor2 != "None"{
                let cutString = MyVariables.sensorDeviceArray2[sender.tag]
                let name = String(cutString.suffix(from: cutString.index(cutString.endIndex, offsetBy: -4)))
                
                MyVariables.sensorCheckboxArray2[sender.tag] = !MyVariables.sensorCheckboxArray2[sender.tag]
                if MyVariables.sensorCheckboxArray2[sender.tag] == true{
                    let uuid = UUID(uuidString: "4D515454-4C" + String(MyVariables.sensor2.suffix(4).prefix(2)) + "-" + String(MyVariables.sensor2.suffix(2)) + "AC-ACAC-ACACACACACAC")!
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0
                  
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.sensorInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.sensor2.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].append("RELAY_SW_" + name)
                            print("在找到的陣列後面新增了 \("RELAY_SW_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.sensor2.suffix(4)).lowercased()],["RELAY_SW_" + name]])
                            print("創建陣列並新增了 \("RELAY_SW_" + name)")
                        }
                    }else{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].append("LIGHT_" + name)
                            print("在找到的陣列後面新增了 \("LIGHT_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.sensor2.suffix(4)).lowercased()],["LIGHT_" + name]])
                            print("創建陣列並新增了 \("LIGHT_" + name)")
                        }
                    }
                }else{
                    let uuid = UUID(uuidString: "4D515454-4C" + String(MyVariables.sensor2.suffix(4).prefix(2)) + "-" + String(MyVariables.sensor2.suffix(2)) + "AD-ADAD-ADADADADADAD")!
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0
      
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.sensorInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.sensor2.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            delay(by: 1) {
                                MyVariables.sensorInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 RELAY_SW_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                        
                    }else{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            delay(by: 1) {
                                MyVariables.sensorInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 LIGHT_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                    }
                }
                
                peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                delay(by: 1){
                    self.peripheralManager?.stopAdvertising()
                }
            }
 
        }else if selectId == 11{
            if MyVariables.sensor3 != "None"{
                let cutString = MyVariables.sensorDeviceArray3[sender.tag]
                let name = String(cutString.suffix(from: cutString.index(cutString.endIndex, offsetBy: -4)))
                
                MyVariables.sensorCheckboxArray3[sender.tag] = !MyVariables.sensorCheckboxArray3[sender.tag]
                if MyVariables.sensorCheckboxArray3[sender.tag] == true{
                    let uuid = UUID(uuidString: "4D515454-4C" + String(MyVariables.sensor3.suffix(4).prefix(2)) + "-" + String(MyVariables.sensor3.suffix(2)) + "AC-ACAC-ACACACACACAC")!
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.sensorInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.sensor3.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].append("RELAY_SW_" + name)
                            print("在找到的陣列後面新增了 \("RELAY_SW_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.sensor3.suffix(4)).lowercased()],["RELAY_SW_" + name]])
                            print("創建陣列並新增了 \("RELAY_SW_" + name)")
                        }
                    }else{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].append("LIGHT_" + name)
                            print("在找到的陣列後面新增了 \("LIGHT_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.sensor3.suffix(4)).lowercased()],["LIGHT_" + name]])
                            print("創建陣列並新增了 \("LIGHT_" + name)")
                        }
                    }
                }else{
                    let uuid = UUID(uuidString: "4D515454-4C" + String(MyVariables.sensor3.suffix(4).prefix(2)) + "-" + String(MyVariables.sensor3.suffix(2)) + "AD-ADAD-ADADADADADAD")!
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0

                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.sensorInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.sensor3.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            delay(by: 1) {
                                MyVariables.sensorInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 RELAY_SW_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                    }else{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            delay(by: 1) {
                                MyVariables.sensorInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 LIGHT_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                    }
                }
                
                peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                delay(by: 1){
                    self.peripheralManager?.stopAdvertising()
                }
            }
 
        }else if selectId == 12{
            if MyVariables.sensor4 != "None"{
                let cutString = MyVariables.sensorDeviceArray4[sender.tag]
                let name = String(cutString.suffix(from: cutString.index(cutString.endIndex, offsetBy: -4)))
                
                MyVariables.sensorCheckboxArray4[sender.tag] = !MyVariables.sensorCheckboxArray4[sender.tag]
                if MyVariables.sensorCheckboxArray4[sender.tag] == true{
                    let uuid = UUID(uuidString: "4D515454-4C" + String(MyVariables.sensor4.suffix(4).prefix(2)) + "-" + String(MyVariables.sensor4.suffix(2)) + "AC-ACAC-ACACACACACAC")!
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.sensorInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.sensor4.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].append("RELAY_SW_" + name)
                            print("在找到的陣列後面新增了 \("RELAY_SW_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.sensor4.suffix(4)).lowercased()],["RELAY_SW_" + name]])
                            print("創建陣列並新增了 \("RELAY_SW_" + name)")
                        }
                    }else{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].append("LIGHT_" + name)
                            print("在找到的陣列後面新增了 \("LIGHT_" + name)")
                        } else {
                            MyVariables.sensorInformations.append([[String(MyVariables.sensor4.suffix(4)).lowercased()],["LIGHT_" + name]])
                            print("創建陣列並新增了 \("LIGHT_" + name)")
                        }
                    }
                }else{
                    let uuid = UUID(uuidString: "4D515454-4C" + String(MyVariables.sensor4.suffix(4).prefix(2)) + "-" + String(MyVariables.sensor4.suffix(2)) + "AD-ADAD-ADADADADADAD")!
                    let localBeaconMajor: UInt16 = UInt16(name, radix: 16)!
                    let localBeaconMinor: UInt16 = 0
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    var foundIndex: Int?
                    for (index, subArray) in MyVariables.sensorInformations.enumerated() {
                        if subArray.contains(where: { $0.contains(String(MyVariables.sensor4.suffix(4)).lowercased()) }) {
                            foundIndex = index
                            break
                        }
                    }
                    
                    if cutString.prefix(5) == "RELAY"{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            delay(by: 1) {
                                MyVariables.sensorInformations[index][1].removeAll { $0.contains("RELAY_SW_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 RELAY_SW_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                    }else{
                        if let index = foundIndex {
                            MyVariables.sensorInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            delay(by: 1) {
                                MyVariables.sensorInformations[index][1].removeAll { $0.contains("LIGHT_" + name) }
                            }//Avoid immediate re-scanning and addition right after removal.
                            
                            print("已从找到的数组中移除了 LIGHT_\(name)")
                        } else {
                            print("找不到目标元素")
                        }
                    }
                }
                
                peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                delay(by: 1){
                    self.peripheralManager?.stopAdvertising()
                }
            }
 
        }

        tableView.reloadData()
    }
    
    
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = longPressGestureRecognizer.location(in: tableView)
            index = tableView.indexPathForRow(at: touchPoint)?.row
            print("LongPress:" + String(Int(index!)))
        }
    }
    
    
}

