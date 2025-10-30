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


class GroupViewController: UIViewController,CBPeripheralManagerDelegate, UIGestureRecognizerDelegate{
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        self.peripheralManager?.startAdvertising(beaconPeripheralData as? [String: Any])
    }
    
    
    var locationManager = CLLocationManager()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lightSwitch: UIButton!
    @IBOutlet weak var lightName: UILabel!
    @IBOutlet weak var levelSlider: UISlider!
    @IBOutlet weak var levelValue: UILabel!
    @IBOutlet weak var colorSlider: UISlider!
    @IBOutlet weak var colorValue: UILabel!
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
    var selected: [Bool] = [false, false, false, false, false]
    var index: Int? = 0
    var selectIndex: Int? = nil
    
    var groupAllTemp = false
    var group1Temp = false
    var group2Temp = false
    var group3Temp = false
    var group4Temp = false
    
    private var recipes = Recipe.createRecipes()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailViewController" {
            if let destinationVC = segue.destination as? DetailViewController {
                destinationVC.selectId = selectIndex!
            }
        }
    }
    
    @IBOutlet weak var version: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        version.text = MyVariables.version
        
        bleFramework = BLEFramework()
        print(bleFramework.GetVersion())
        bleFramework.Initialize()
        let iPhoneVersion = PhoneInformation()
        bleFramework.largeMTU = iPhoneVersion.GetDeviceInfo()
        
//        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(GroupViewController.longPress(longPressGestureRecognizer:)))
//        longPressRecognizer.minimumPressDuration = 1.0 // 1 second press
//        longPressRecognizer.delegate = self
//        self.view.addGestureRecognizer(longPressRecognizer)
        
        levelSlider.minimumValue = 1
        levelSlider.maximumValue = 100
        colorSlider.minimumValue = 0
        colorSlider.maximumValue = 100
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager?
    
    public func delay(by delayTime: TimeInterval, qosClass: DispatchQoS.QoSClass? = nil,_ closure: @escaping () -> Void) {
        let dispatchQueue = qosClass != nil ? DispatchQueue.global(qos: qosClass!) : .main
        dispatchQueue.asyncAfter(deadline: DispatchTime.now() + delayTime, execute: closure)
    }
    
    //Cache Document
    func getDocumentsPath(path: String) -> String? {
        let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last as NSString?
        let filePath = docPath?.appendingPathComponent(path);
        return filePath
    }
    
    @IBAction func Switch(_ sender: Any) {
        
        if index != nil{
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            self.peripheralManager?.stopAdvertising()
            
            if lightName.text == "ALL"{
                if groupAllTemp == false{
                    groupAllTemp = true
                    let uuid = UUID(uuidString: "52455454-4c00-0000-0000-000080000000")!
                    let localBeaconMajor: CLBeaconMajorValue = 0
                    let localBeaconMinor: CLBeaconMinorValue = 1
                    lightSwitch.setImage(UIImage(named: "Power on.png"), for: .normal)
                    levelValue.text = "Level：" + String(100)
                    colorValue.text = "Color：" + String(100)
                    levelSlider.value = Float(100)
                    colorSlider.value = Float(100)
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                    delay(by: 1){
                        self.peripheralManager?.stopAdvertising()
                    }
                }else{
                    groupAllTemp = false
                    let uuid = UUID(uuidString: "52455454-4c00-0000-0000-000080000000")!
                    let localBeaconMajor: CLBeaconMajorValue = 0
                    let localBeaconMinor: CLBeaconMinorValue = 0
                    lightSwitch.setImage(UIImage(named: "Power off.png"), for: .normal)
                    levelValue.text = "Level：" + String(0)
                    colorValue.text = "Color：" + String(0)
                    levelSlider.value = Float(0)
                    colorSlider.value = Float(0)
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                    delay(by: 1){
                        self.peripheralManager?.stopAdvertising()
                    }
                }
            }else if lightName.text == "Group1"{
                if group1Temp == false{
                    group1Temp = true
                    let uuid = UUID(uuidString: "52455454-4c00-0000-0000-000000010000")!
                    let localBeaconMajor: CLBeaconMajorValue = 0
                    let localBeaconMinor: CLBeaconMinorValue = 1
                    lightSwitch.setImage(UIImage(named: "Power on.png"), for: .normal)
                    levelValue.text = "Level：" + String(100)
                    colorValue.text = "Color：" + String(100)
                    levelSlider.value = Float(100)
                    colorSlider.value = Float(100)
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                    delay(by: 1){
                        self.peripheralManager?.stopAdvertising()
                    }
                }else{
                    group1Temp = false
                    let uuid = UUID(uuidString: "52455454-4c00-0000-0000-000000010000")!
                    let localBeaconMajor: CLBeaconMajorValue = 0
                    let localBeaconMinor: CLBeaconMinorValue = 0
                    lightSwitch.setImage(UIImage(named: "Power off.png"), for: .normal)
                    levelValue.text = "Level：" + String(0)
                    colorValue.text = "Color：" + String(0)
                    levelSlider.value = Float(0)
                    colorSlider.value = Float(0)
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                    delay(by: 1){
                        self.peripheralManager?.stopAdvertising()
                    }
                }
                
            }else if lightName.text == "Group2"{
                if group2Temp == false{
                    group2Temp = true
                    let uuid = UUID(uuidString: "52455454-4c00-0000-0000-000000020000")!
                    let localBeaconMajor: CLBeaconMajorValue = 0
                    let localBeaconMinor: CLBeaconMinorValue = 1
                    lightSwitch.setImage(UIImage(named: "Power on.png"), for: .normal)
                    levelValue.text = "Level：" + String(100)
                    colorValue.text = "Color：" + String(100)
                    levelSlider.value = Float(100)
                    colorSlider.value = Float(100)
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                    delay(by: 1){
                        self.peripheralManager?.stopAdvertising()
                    }
                }else{
                    group2Temp = false
                    let uuid = UUID(uuidString: "52455454-4c00-0000-0000-000000020000")!
                    let localBeaconMajor: CLBeaconMajorValue = 0
                    let localBeaconMinor: CLBeaconMinorValue = 0
                    lightSwitch.setImage(UIImage(named: "Power off.png"), for: .normal)
                    levelValue.text = "Level：" + String(0)
                    colorValue.text = "Color：" + String(0)
                    levelSlider.value = Float(0)
                    colorSlider.value = Float(0)
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                    delay(by: 1){
                        self.peripheralManager?.stopAdvertising()
                    }
                }
                
            }else if lightName.text == "Group3"{
                if group3Temp == false{
                    group3Temp = true
                    let uuid = UUID(uuidString: "52455454-4c00-0000-0000-000000040000")!
                    let localBeaconMajor: CLBeaconMajorValue = 0
                    let localBeaconMinor: CLBeaconMinorValue = 1
                    lightSwitch.setImage(UIImage(named: "Power on.png"), for: .normal)
                    levelValue.text = "Level：" + String(100)
                    colorValue.text = "Color：" + String(100)
                    levelSlider.value = Float(100)
                    colorSlider.value = Float(100)
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                    delay(by: 1){
                        self.peripheralManager?.stopAdvertising()
                    }
                }else{
                    group3Temp = false
                    let uuid = UUID(uuidString: "52455454-4c00-0000-0000-000000040000")!
                    let localBeaconMajor: CLBeaconMajorValue = 0
                    let localBeaconMinor: CLBeaconMinorValue = 0
                    lightSwitch.setImage(UIImage(named: "Power off.png"), for: .normal)
                    levelValue.text = "Level：" + String(0)
                    colorValue.text = "Color：" + String(0)
                    levelSlider.value = Float(0)
                    colorSlider.value = Float(0)
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                    delay(by: 1){
                        self.peripheralManager?.stopAdvertising()
                    }
                }
                
            }else if lightName.text == "Group4"{
                if group4Temp == false{
                    group4Temp = true
                    let uuid = UUID(uuidString: "52455454-4c00-0000-0000-000000080000")!
                    let localBeaconMajor: CLBeaconMajorValue = 0
                    let localBeaconMinor: CLBeaconMinorValue = 1
                    lightSwitch.setImage(UIImage(named: "Power on.png"), for: .normal)
                    levelValue.text = "Level：" + String(100)
                    colorValue.text = "Color：" + String(100)
                    levelSlider.value = Float(100)
                    colorSlider.value = Float(100)
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                    delay(by: 1){
                        self.peripheralManager?.stopAdvertising()
                    }
                }else{
                    group4Temp = false
                    let uuid = UUID(uuidString: "52455454-4c00-0000-0000-000000080000")!
                    let localBeaconMajor: CLBeaconMajorValue = 0
                    let localBeaconMinor: CLBeaconMinorValue = 0
                    lightSwitch.setImage(UIImage(named: "Power off.png"), for: .normal)
                    levelValue.text = "Level：" + String(0)
                    colorValue.text = "Color：" + String(0)
                    levelSlider.value = Float(0)
                    colorSlider.value = Float(0)
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                    delay(by: 1){
                        self.peripheralManager?.stopAdvertising()
                    }
                }
                
            }
            

        }
    }
    
    @IBAction func levelSlider(_ sender: UISlider) {
        
        if index != nil{
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            self.peripheralManager?.stopAdvertising()
            
            if lightName.text == "ALL"{
                let uuid = UUID(uuidString: "52455454-4c00-0000-0000-000080002000")!
                let localBeaconMajor: CLBeaconMajorValue = 0
                let localBeaconMinor: CLBeaconMinorValue = CLBeaconMinorValue(Int(levelSlider.value))

                levelValue.text = "Level：" + String(Int(levelSlider.value))
                
                localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                
                peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                delay(by: 1){
                    self.peripheralManager?.stopAdvertising()
                }
            }else if lightName.text == "Group1"{
                let uuid = UUID(uuidString: "52455454-4c00-0000-0000-000000012000")!
                let localBeaconMajor: CLBeaconMajorValue = 0
                let localBeaconMinor: CLBeaconMinorValue = CLBeaconMinorValue(Int(levelSlider.value))

                levelValue.text = "Level：" + String(Int(levelSlider.value))
                
                localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                
                peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                delay(by: 1){
                    self.peripheralManager?.stopAdvertising()
                }
                
            }else if lightName.text == "Group2"{
                let uuid = UUID(uuidString: "52455454-4c00-0000-0000-000000022000")!
                let localBeaconMajor: CLBeaconMajorValue = 0
                let localBeaconMinor: CLBeaconMinorValue = CLBeaconMinorValue(Int(levelSlider.value))

                levelValue.text = "Level：" + String(Int(levelSlider.value))
                
                localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                
                peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                delay(by: 1){
                    self.peripheralManager?.stopAdvertising()
                }
                
            }else if lightName.text == "Group3"{
                let uuid = UUID(uuidString: "52455454-4c00-0000-0000-000000042000")!
                let localBeaconMajor: CLBeaconMajorValue = 0
                let localBeaconMinor: CLBeaconMinorValue = CLBeaconMinorValue(Int(levelSlider.value))

                levelValue.text = "Level：" + String(Int(levelSlider.value))
                
                localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                
                peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                delay(by: 1){
                    self.peripheralManager?.stopAdvertising()
                }
                
            }else if lightName.text == "Group4"{
                let uuid = UUID(uuidString: "52455454-4c00-0000-0000-000000082000")!
                let localBeaconMajor: CLBeaconMajorValue = 0
                let localBeaconMinor: CLBeaconMinorValue = CLBeaconMinorValue(Int(levelSlider.value))

                levelValue.text = "Level：" + String(Int(levelSlider.value))
                
                localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                
                peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                delay(by: 1){
                    self.peripheralManager?.stopAdvertising()
                }
                
            }
        }
    }
    @IBAction func colorSlider(_ sender: Any) {
        if index != nil{
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            self.peripheralManager?.stopAdvertising()
            
            if lightName.text == "ALL"{
                let uuid = UUID(uuidString: "52455454-4c00-0000-0000-000080004000")!
                let localBeaconMajor: CLBeaconMajorValue = 0
                let localBeaconMinor: CLBeaconMinorValue = CLBeaconMinorValue(Int(colorSlider.value))

                colorValue.text = "Color：" + String(Int(colorSlider.value))
                
                localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                
                peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                delay(by: 1){
                    self.peripheralManager?.stopAdvertising()
                }
            }else if lightName.text == "Group1"{
                let uuid = UUID(uuidString: "52455454-4c00-0000-0000-000000014000")!
                let localBeaconMajor: CLBeaconMajorValue = 0
                let localBeaconMinor: CLBeaconMinorValue = CLBeaconMinorValue(Int(colorSlider.value))

                colorValue.text = "Color：" + String(Int(colorSlider.value))
                
                localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                
                peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                delay(by: 1){
                    self.peripheralManager?.stopAdvertising()
                }
                
            }else if lightName.text == "Group2"{
                let uuid = UUID(uuidString: "52455454-4c00-0000-0000-000000024000")!
                let localBeaconMajor: CLBeaconMajorValue = 0
                let localBeaconMinor: CLBeaconMinorValue = CLBeaconMinorValue(Int(colorSlider.value))

                colorValue.text = "Color：" + String(Int(colorSlider.value))
                
                localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                
                peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                delay(by: 1){
                    self.peripheralManager?.stopAdvertising()
                }
                
            }else if lightName.text == "Group3"{
                let uuid = UUID(uuidString: "52455454-4c00-0000-0000-000000044000")!
                let localBeaconMajor: CLBeaconMajorValue = 0
                let localBeaconMinor: CLBeaconMinorValue = CLBeaconMinorValue(Int(colorSlider.value))

                colorValue.text = "Color：" + String(Int(colorSlider.value))
                
                localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                
                peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                delay(by: 1){
                    self.peripheralManager?.stopAdvertising()
                }
                
            }else if lightName.text == "Group4"{
                let uuid = UUID(uuidString: "52455454-4c00-0000-0000-000000084000")!
                let localBeaconMajor: CLBeaconMajorValue = 0
                let localBeaconMinor: CLBeaconMinorValue = CLBeaconMinorValue(Int(colorSlider.value))

                colorValue.text = "Color：" + String(Int(colorSlider.value))
                
                localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                
                peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                delay(by: 1){
                    self.peripheralManager?.stopAdvertising()
                }
                
            }
        }
        
        
    }
  
   
}

extension GroupViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: "GroupTableCell") as? GroupTableCell {
            
            let button = UIButton(type: .custom)
            button.setImage(UIImage(systemName: "text.badge.plus"), for: .normal)
            button.setPreferredSymbolConfiguration(.init(scale: UIImage.SymbolScale.large), forImageIn: .normal)
            button.sizeToFit()
            button.tag = indexPath.row
            button.addTarget(self, action: #selector(detailPressed), for: .touchUpInside)
            
            cell.configurateTheCell(recipes[indexPath.row])
            cell.accessoryView = button
            cell.selectionStyle = .none
            
            if selected[indexPath.row]{
                cell.groupName.textColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            }else{
                cell.groupName.textColor = .black
            }
            
            return cell
        }
        return UITableViewCell()

        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        index = indexPath.row
        
        lightName.text = recipes[indexPath.row].groupName
        
        for i in 0...selected.count-1{
            selected[i] = false
        }
        selected[index!] = true
        tableView.reloadData()
    }
    
    @objc func detailPressed(sender: UIButton){
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        selectIndex = sender.tag
        performSegue(withIdentifier: "detailViewController", sender: sender)
    }
    
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = longPressGestureRecognizer.location(in: tableView)
            index = tableView.indexPathForRow(at: touchPoint)?.row
            print("LongPress:" + String(Int(index!)))
            
            var alertStyle = UIAlertController.Style.actionSheet
            if (UIDevice.current.userInterfaceIdiom == .pad) {
              alertStyle = UIAlertController.Style.alert
            }
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: alertStyle)
            alert.addAction(UIAlertAction(title: "Sensor mode", style: .default, handler: { [self] _ in
                print("Sensor mode")
                let uuid = UUID(uuidString: "52455454-4c00-0000-0000-00008000e003")!
                let localBeaconMajor: CLBeaconMajorValue = 0
                let localBeaconMinor: CLBeaconMinorValue = 0

                
                localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                
                peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                delay(by: 1){
                    self.peripheralManager?.stopAdvertising()
                }
            }))
            alert.addAction(UIAlertAction(title: "Control mode", style: .default, handler: { [self] _ in
                print("Control mode")
                let uuid = UUID(uuidString: "52455454-4c00-0000-0000-00008000e000")!
                let localBeaconMajor: CLBeaconMajorValue = 0
                let localBeaconMinor: CLBeaconMinorValue = 0

                
                localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                
                peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                delay(by: 1){
                    self.peripheralManager?.stopAdvertising()
                }
            }))
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
}

