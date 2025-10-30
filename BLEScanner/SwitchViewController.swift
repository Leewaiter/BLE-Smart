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



class SwitchViewController: UIViewController,CBPeripheralManagerDelegate, UIGestureRecognizerDelegate{
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
    
    
    var switch1Temp = false
    var switch2Temp = false
    var switch3Temp = false
    var switch4Temp = false
    
    
    private var recipes = RecipeSwitch.createRecipes(switch1: MyVariables.switch1,
                                                     switch2: MyVariables.switch2,
                                                     switch3: MyVariables.switch3,
                                                     switch4: MyVariables.switch4)
    
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
        
        //讀檔
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: getDocumentsPath(path: "DataModelSwitch")!))
            if let model = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? DataModelSwitch{
            }
        } catch {
            print("unarchive failure in init")
        }
        print("switch1:", MyVariables.switch1)
        print("switch2:", MyVariables.switch2)
        print("switch3:", MyVariables.switch3)
        print("switch4:", MyVariables.switch4)
        
        recipes = RecipeSwitch.createRecipes(switch1: MyVariables.switch1,
                                             switch2: MyVariables.switch2,
                                             switch3: MyVariables.switch3,
                                             switch4: MyVariables.switch4)
        
        bleFramework = BLEFramework()
        print(bleFramework.GetVersion())
        bleFramework.Initialize()
        let iPhoneVersion = PhoneInformation()
        bleFramework.largeMTU = iPhoneVersion.GetDeviceInfo()
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(GroupViewController.longPress(longPressGestureRecognizer:)))
        longPressRecognizer.minimumPressDuration = 1.0 // 1 second press
        longPressRecognizer.delegate = self
        self.view.addGestureRecognizer(longPressRecognizer)
        
        
        
        levelSlider.minimumValue = 1
        levelSlider.maximumValue = 100
        colorSlider.minimumValue = 0
        colorSlider.maximumValue = 100
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        var timerUpdate = Timer()
        timerUpdate = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(reloadData), userInfo: nil, repeats: true)

        
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
    
    
    
    @objc func reloadData() {
        recipes = RecipeSwitch.createRecipes(switch1: MyVariables.switch1,
                                         switch2: MyVariables.switch2,
                                         switch3: MyVariables.switch3,
                                         switch4: MyVariables.switch4)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
    }
    
    //Cache Document
    func getDocumentsPath(path: String) -> String? {
        let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last as NSString?
        let filePath = docPath?.appendingPathComponent(path);
        return filePath
    }
    
    @IBAction func Switch(_ sender: Any) {
        print(MyVariables.switch2)
        if index != nil{
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            self.peripheralManager?.stopAdvertising()
            
            if lightName.text == MyVariables.switch1 && MyVariables.switch1 != "None"{
                for i in 1...MyVariables.switchCheckboxArray1.count{
                    
                    if MyVariables.switchCheckboxArray1[i-1] == true{
                        print(MyVariables.switchDeviceArray1[i-1])
                    }
                }
                if switch1Temp == false{
                    switch1Temp = true
                    var uuid: UUID
                    if MyVariables.switch1.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch1.suffix(4)) + "-0000-" + String(MyVariables.switch1.suffix(4)) + "00000000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch1.suffix(4)) + "-0100-" + String(MyVariables.switch1.suffix(4)) + "00000000")!
                    }
                    
                    let localBeaconMajor: CLBeaconMajorValue = 50
                    let localBeaconMinor: CLBeaconMinorValue = 50
                    lightSwitch.setImage(UIImage(named: "Power on.png"), for: .normal)
                    levelValue.text = "Level：" + String(50)
                    colorValue.text = "Color：" + String(50)
                    levelSlider.value = Float(50)
                    colorSlider.value = Float(50)
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                    delay(by: 1){
                        self.peripheralManager?.stopAdvertising()
                    }
                }else{
                    switch1Temp = false
                    var uuid: UUID
                    if MyVariables.switch1.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch1.suffix(4)) + "-0000-" + String(MyVariables.switch1.suffix(4)) + "00000000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch1.suffix(4)) + "-0100-" + String(MyVariables.switch1.suffix(4)) + "00000000")!
                    }
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
                
            }else if lightName.text == MyVariables.switch2 && MyVariables.switch2 != "None"{
                for i in 1...MyVariables.switchCheckboxArray2.count{
                    
                    if MyVariables.switchCheckboxArray2[i-1] == true{
                        print(MyVariables.switchDeviceArray2[i-1])
                    }
                }
                
                if switch2Temp == false{
                    switch2Temp = true
                    var uuid: UUID
                    if MyVariables.switch2.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch2.suffix(4)) + "-0000-" + String(MyVariables.switch2.suffix(4)) + "00000000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch2.suffix(4)) + "-0100-" + String(MyVariables.switch2.suffix(4)) + "00000000")!
                    }
                    let localBeaconMajor: CLBeaconMajorValue = 50
                    let localBeaconMinor: CLBeaconMinorValue = 50
                    lightSwitch.setImage(UIImage(named: "Power on.png"), for: .normal)
                    levelValue.text = "Level：" + String(50)
                    colorValue.text = "Color：" + String(50)
                    levelSlider.value = Float(50)
                    colorSlider.value = Float(50)
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                    delay(by: 1){
                        self.peripheralManager?.stopAdvertising()
                    }
                }else{
                    switch2Temp = false
                    var uuid: UUID
                    if MyVariables.switch2.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch2.suffix(4)) + "-0000-" + String(MyVariables.switch2.suffix(4)) + "00000000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch2.suffix(4)) + "-0100-" + String(MyVariables.switch2.suffix(4)) + "00000000")!
                    }
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
                
            }else if lightName.text == MyVariables.switch3 && MyVariables.switch3 != "None"{
                for i in 1...MyVariables.switchCheckboxArray3.count{
                    
                    if MyVariables.switchCheckboxArray3[i-1] == true{
                        print(MyVariables.switchDeviceArray3[i-1])
                    }
                }
                
                if switch3Temp == false{
                    switch3Temp = true
                    var uuid: UUID
                    if MyVariables.switch3.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch3.suffix(4)) + "-0000-" + String(MyVariables.switch3.suffix(4)) + "00000000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch3.suffix(4)) + "-0100-" + String(MyVariables.switch3.suffix(4)) + "00000000")!
                    }
                    let localBeaconMajor: CLBeaconMajorValue = 50
                    let localBeaconMinor: CLBeaconMinorValue = 50
                    lightSwitch.setImage(UIImage(named: "Power on.png"), for: .normal)
                    levelValue.text = "Level：" + String(50)
                    colorValue.text = "Color：" + String(50)
                    levelSlider.value = Float(50)
                    colorSlider.value = Float(50)
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                    delay(by: 1){
                        self.peripheralManager?.stopAdvertising()
                    }
                }else{
                    switch3Temp = false
                    var uuid: UUID
                    if MyVariables.switch3.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch3.suffix(4)) + "-0000-" + String(MyVariables.switch3.suffix(4)) + "00000000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch3.suffix(4)) + "-0100-" + String(MyVariables.switch3.suffix(4)) + "00000000")!
                    }
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
                
            }else if lightName.text == MyVariables.switch4 && MyVariables.switch4 != "None"{
                for i in 1...MyVariables.switchCheckboxArray4.count{
                    
                    if MyVariables.switchCheckboxArray4[i-1] == true{
                        print(MyVariables.switchDeviceArray4[i-1])
                    }
                }
                
                if switch4Temp == false{
                    switch4Temp = true
                    var uuid: UUID
                    if MyVariables.switch4.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch4.suffix(4)) + "-0000-" + String(MyVariables.switch4.suffix(4)) + "00000000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch4.suffix(4)) + "-0100-" + String(MyVariables.switch4.suffix(4)) + "00000000")!
                    }
                    let localBeaconMajor: CLBeaconMajorValue = 50
                    let localBeaconMinor: CLBeaconMinorValue = 50
                    lightSwitch.setImage(UIImage(named: "Power on.png"), for: .normal)
                    levelValue.text = "Level：" + String(50)
                    colorValue.text = "Color：" + String(50)
                    levelSlider.value = Float(50)
                    colorSlider.value = Float(50)
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                    delay(by: 1){
                        self.peripheralManager?.stopAdvertising()
                    }
                }else{
                    switch4Temp = false
                    var uuid: UUID
                    if MyVariables.switch4.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch4.suffix(4)) + "-0000-" + String(MyVariables.switch4.suffix(4)) + "00000000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch4.suffix(4)) + "-0100-" + String(MyVariables.switch4.suffix(4)) + "00000000")!
                    }
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
            
            if lightName.text == MyVariables.switch1 && MyVariables.switch1 != "None"{

                if switch1Temp == true {
                    var uuid: UUID
                    if MyVariables.switch1.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch1.suffix(4)) + "-0000-" + String(MyVariables.switch1.suffix(4)) + "00000000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch1.suffix(4)) + "-0100-" + String(MyVariables.switch1.suffix(4)) + "00000000")!
                    }
                    let localBeaconMajor: CLBeaconMajorValue = CLBeaconMinorValue(Int(levelSlider.value))
                    let localBeaconMinor: CLBeaconMinorValue = CLBeaconMinorValue(Int(colorSlider.value))
                    levelValue.text = "Level：" + String(Int(levelSlider.value))
                    colorValue.text = "Color：" + String(Int(colorSlider.value))
                    levelSlider.value = Float(Int(levelSlider.value))
                    colorSlider.value = Float(Int(colorSlider.value))
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                    delay(by: 1){
                        self.peripheralManager?.stopAdvertising()
                    }
                }else{
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    levelValue.text = "Level：xx"
                    colorValue.text = "Color：xx"
                    levelSlider.value = Float(0)
                    colorSlider.value = Float(0)
                }
                
            }else if lightName.text == MyVariables.switch2 && MyVariables.switch2 != "None"{

                if switch2Temp == true {
                    var uuid: UUID
                    if MyVariables.switch2.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch2.suffix(4)) + "-0000-" + String(MyVariables.switch2.suffix(4)) + "00000000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch2.suffix(4)) + "-0100-" + String(MyVariables.switch2.suffix(4)) + "00000000")!
                    }
                    let localBeaconMajor: CLBeaconMajorValue = CLBeaconMinorValue(Int(levelSlider.value))
                    let localBeaconMinor: CLBeaconMinorValue = CLBeaconMinorValue(Int(colorSlider.value))
                    levelValue.text = "Level：" + String(Int(levelSlider.value))
                    colorValue.text = "Color：" + String(Int(colorSlider.value))
                    levelSlider.value = Float(Int(levelSlider.value))
                    colorSlider.value = Float(Int(colorSlider.value))
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                    delay(by: 1){
                        self.peripheralManager?.stopAdvertising()
                    }
                }else{
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    levelValue.text = "Level：xx"
                    colorValue.text = "Color：xx"
                    levelSlider.value = Float(0)
                    colorSlider.value = Float(0)
                }
                
            }else if lightName.text == MyVariables.switch3 && MyVariables.switch3 != "None"{
                
                if switch3Temp == true {
                    var uuid: UUID
                    if MyVariables.switch3.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch3.suffix(4)) + "-0000-" + String(MyVariables.switch3.suffix(4)) + "00000000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch3.suffix(4)) + "-0100-" + String(MyVariables.switch3.suffix(4)) + "00000000")!
                    }
                    let localBeaconMajor: CLBeaconMajorValue = CLBeaconMinorValue(Int(levelSlider.value))
                    let localBeaconMinor: CLBeaconMinorValue = CLBeaconMinorValue(Int(colorSlider.value))
                    levelValue.text = "Level：" + String(Int(levelSlider.value))
                    colorValue.text = "Color：" + String(Int(colorSlider.value))
                    levelSlider.value = Float(Int(levelSlider.value))
                    colorSlider.value = Float(Int(colorSlider.value))
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                    delay(by: 1){
                        self.peripheralManager?.stopAdvertising()
                    }
                }else{
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    levelValue.text = "Level：xx"
                    colorValue.text = "Color：xx"
                    levelSlider.value = Float(0)
                    colorSlider.value = Float(0)
                }
                
            }else if lightName.text == MyVariables.switch4 && MyVariables.switch4 != "None"{
                
                if switch4Temp == true {
                    var uuid: UUID
                    if MyVariables.switch4.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch4.suffix(4)) + "-0000-" + String(MyVariables.switch4.suffix(4)) + "00000000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch4.suffix(4)) + "-0100-" + String(MyVariables.switch4.suffix(4)) + "00000000")!
                    }
                    let localBeaconMajor: CLBeaconMajorValue = CLBeaconMinorValue(Int(levelSlider.value))
                    let localBeaconMinor: CLBeaconMinorValue = CLBeaconMinorValue(Int(colorSlider.value))
                    levelValue.text = "Level：" + String(Int(levelSlider.value))
                    colorValue.text = "Color：" + String(Int(colorSlider.value))
                    levelSlider.value = Float(Int(levelSlider.value))
                    colorSlider.value = Float(Int(colorSlider.value))
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                    delay(by: 1){
                        self.peripheralManager?.stopAdvertising()
                    }
                }else{
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    levelValue.text = "Level：xx"
                    colorValue.text = "Color：xx"
                    levelSlider.value = Float(0)
                    colorSlider.value = Float(0)
                }
                
            }else if lightName.text! == "None"{
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                levelValue.text = "Level：xx"
                colorValue.text = "Color：xx"
                levelSlider.value = Float(0)
                colorSlider.value = Float(0)
            }
            
        }
    }
    @IBAction func colorSlider(_ sender: Any) {
        if index != nil{
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            self.peripheralManager?.stopAdvertising()
            
            if lightName.text == MyVariables.switch1 && MyVariables.switch1 != "None"{

                if switch1Temp == true {
                    var uuid: UUID
                    if MyVariables.switch1.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch1.suffix(4)) + "-0000-" + String(MyVariables.switch1.suffix(4)) + "00000000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch1.suffix(4)) + "-0100-" + String(MyVariables.switch1.suffix(4)) + "00000000")!
                    }
                    let localBeaconMajor: CLBeaconMajorValue = CLBeaconMinorValue(Int(levelSlider.value))
                    let localBeaconMinor: CLBeaconMinorValue = CLBeaconMinorValue(Int(colorSlider.value))
                    levelValue.text = "Level：" + String(Int(levelSlider.value))
                    colorValue.text = "Color：" + String(Int(colorSlider.value))
                    levelSlider.value = Float(Int(levelSlider.value))
                    colorSlider.value = Float(Int(colorSlider.value))
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                    delay(by: 1){
                        self.peripheralManager?.stopAdvertising()
                    }
                }else{
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    levelValue.text = "Level：xx"
                    colorValue.text = "Color：xx"
                    levelSlider.value = Float(0)
                    colorSlider.value = Float(0)
                }
                
            }else if lightName.text == MyVariables.switch2 && MyVariables.switch2 != "None"{

                if switch2Temp == true {
                    var uuid: UUID
                    if MyVariables.switch2.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch2.suffix(4)) + "-0000-" + String(MyVariables.switch2.suffix(4)) + "00000000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch2.suffix(4)) + "-0100-" + String(MyVariables.switch2.suffix(4)) + "00000000")!
                    }
                    let localBeaconMajor: CLBeaconMajorValue = CLBeaconMinorValue(Int(levelSlider.value))
                    let localBeaconMinor: CLBeaconMinorValue = CLBeaconMinorValue(Int(colorSlider.value))
                    levelValue.text = "Level：" + String(Int(levelSlider.value))
                    colorValue.text = "Color：" + String(Int(colorSlider.value))
                    levelSlider.value = Float(Int(levelSlider.value))
                    colorSlider.value = Float(Int(colorSlider.value))
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                    delay(by: 1){
                        self.peripheralManager?.stopAdvertising()
                    }
                }else{
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    levelValue.text = "Level：xx"
                    colorValue.text = "Color：xx"
                    levelSlider.value = Float(0)
                    colorSlider.value = Float(0)
                }
                
            }else if lightName.text == MyVariables.switch3 && MyVariables.switch3 != "None"{
                
                if switch3Temp == true {
                    var uuid: UUID
                    if MyVariables.switch3.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch3.suffix(4)) + "-0000-" + String(MyVariables.switch3.suffix(4)) + "00000000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch3.suffix(4)) + "-0100-" + String(MyVariables.switch3.suffix(4)) + "00000000")!
                    }
                    let localBeaconMajor: CLBeaconMajorValue = CLBeaconMinorValue(Int(levelSlider.value))
                    let localBeaconMinor: CLBeaconMinorValue = CLBeaconMinorValue(Int(colorSlider.value))
                    levelValue.text = "Level：" + String(Int(levelSlider.value))
                    colorValue.text = "Color：" + String(Int(colorSlider.value))
                    levelSlider.value = Float(Int(levelSlider.value))
                    colorSlider.value = Float(Int(colorSlider.value))
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                    delay(by: 1){
                        self.peripheralManager?.stopAdvertising()
                    }
                }else{
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    levelValue.text = "Level：xx"
                    colorValue.text = "Color：xx"
                    levelSlider.value = Float(0)
                    colorSlider.value = Float(0)
                }
                
            }else if lightName.text == MyVariables.switch4 && MyVariables.switch4 != "None"{
                
                if switch4Temp == true {
                    var uuid: UUID
                    if MyVariables.switch4.prefix(4) == "WSW4"{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch4.suffix(4)) + "-0000-" + String(MyVariables.switch4.suffix(4)) + "00000000")!
                    }else{
                        uuid = UUID(uuidString: "53574954-4348-" + String(MyVariables.switch4.suffix(4)) + "-0100-" + String(MyVariables.switch4.suffix(4)) + "00000000")!
                    }
                    let localBeaconMajor: CLBeaconMajorValue = CLBeaconMinorValue(Int(levelSlider.value))
                    let localBeaconMinor: CLBeaconMinorValue = CLBeaconMinorValue(Int(colorSlider.value))
                    levelValue.text = "Level：" + String(Int(levelSlider.value))
                    colorValue.text = "Color：" + String(Int(colorSlider.value))
                    levelSlider.value = Float(Int(levelSlider.value))
                    colorSlider.value = Float(Int(colorSlider.value))
                    
                    localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
                    beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                    
                    peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                    delay(by: 1){
                        self.peripheralManager?.stopAdvertising()
                    }
                }else{
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    levelValue.text = "Level：xx"
                    colorValue.text = "Color：xx"
                    levelSlider.value = Float(0)
                    colorSlider.value = Float(0)
                }
                
            }else if lightName.text! == "None"{
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                levelValue.text = "Level：xx"
                colorValue.text = "Color：xx"
                levelSlider.value = Float(0)
                colorSlider.value = Float(0)
            }
            
        }
        
        
    }
  
   
}

extension SwitchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableCell") as? SwitchTableCell {

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
                cell.switchName.textColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            }else{
                cell.switchName.textColor = .black
            }
            
            
            return cell
        }
        
        
        
        return UITableViewCell()

        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        index = indexPath.row
        
        lightName.text = recipes[indexPath.row].switchName
        
        
        if lightName.text == "None"{
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            
            showSwitchAlert(for: indexPath)
            
            lightSwitch.setImage(UIImage(named: "Power off.png"), for: .normal)
            levelValue.text = "Level：xx"
            colorValue.text = "Color：xx"
            levelSlider.value = Float(0)
            colorSlider.value = Float(0)
        }else if lightName.text == MyVariables.switch1{
            if switch1Temp == true{
                lightSwitch.setImage(UIImage(named: "Power on.png"), for: .normal)
            }else{
                lightSwitch.setImage(UIImage(named: "Power off.png"), for: .normal)
            }
        }else if lightName.text == MyVariables.switch2{
            if switch2Temp == true{
                lightSwitch.setImage(UIImage(named: "Power on.png"), for: .normal)
            }else{
                lightSwitch.setImage(UIImage(named: "Power off.png"), for: .normal)
            }
        }else if lightName.text == MyVariables.switch3{
            if switch3Temp == true{
                lightSwitch.setImage(UIImage(named: "Power on.png"), for: .normal)
            }else{
                lightSwitch.setImage(UIImage(named: "Power off.png"), for: .normal)
            }
        }else if lightName.text == MyVariables.switch4{
            if switch4Temp == true{
                lightSwitch.setImage(UIImage(named: "Power on.png"), for: .normal)
            }else{
                lightSwitch.setImage(UIImage(named: "Power off.png"), for: .normal)
            }
        }
        
        for i in 0...selected.count-1{
            selected[i] = false
        }
        selected[index!] = true
        
        
        
        tableView.reloadData()
    }
    
    @objc func detailPressed(sender: UIButton){
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        selectIndex = sender.tag + 5
        performSegue(withIdentifier: "detailViewController", sender: selectIndex)
    }
    
    func showSwitchAlert(for indexPath: IndexPath) {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        MyVariables.switchChoose = indexPath.row
        print("press: \(indexPath.row)")
        
        var alertStyle = UIAlertController.Style.actionSheet
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertStyle = UIAlertController.Style.alert
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: alertStyle)
        
        alert.addAction(UIAlertAction(title: "Scan", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.selectIndex = indexPath.row
            self.performSegue(withIdentifier: "switchScanViewController", sender: self.selectIndex)
        })
        
        alert.addAction(UIAlertAction(title: "Remove", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.selectIndex = indexPath.row
            
            // 安全處理 switch（避免 nil）
            switch self.selectIndex {
            case 0: MyVariables.switch1 = "None"
            case 1: MyVariables.switch2 = "None"
            case 2: MyVariables.switch3 = "None"
            case 3: MyVariables.switch4 = "None"
            default: print("Invalid index: \(self.selectIndex)")
            }
            
            // 歸檔
            let model = DataModelSwitch()
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: model, requiringSecureCoding: false)
                try data.write(to: URL(fileURLWithPath: self.getDocumentsPath(path: "DataModelSwitch")!))
            } catch {
                print(error)
            }
            
            // 重新創建 recipes 並 reload
            self.recipes = RecipeSwitch.createRecipes(
                switch1: MyVariables.switch1,
                switch2: MyVariables.switch2,
                switch3: MyVariables.switch3,
                switch4: MyVariables.switch4
            )
            self.tableView.reloadData()  // 僅在這裡 reload
        })
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = longPressGestureRecognizer.location(in: tableView)
            index = tableView.indexPathForRow(at: touchPoint)?.row
            MyVariables.switchChoose = index!
            print("LongPress:" + String(Int(index!)))
            
            var alertStyle = UIAlertController.Style.actionSheet
            if (UIDevice.current.userInterfaceIdiom == .pad) {
              alertStyle = UIAlertController.Style.alert
            }
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: alertStyle)
            alert.addAction(UIAlertAction(title: "Scan", style: .default, handler: { [self] _ in
                UINotificationFeedbackGenerator().notificationOccurred(.success)

                selectIndex = tableView.indexPathForRow(at: touchPoint)?.row
                performSegue(withIdentifier: "switchScanViewController", sender: selectIndex)

            }))
            alert.addAction(UIAlertAction(title: "Remove", style: .default, handler: { [self] _ in
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                
                selectIndex = tableView.indexPathForRow(at: touchPoint)?.row
                
                switch selectIndex{
                case 0:
                    MyVariables.switch1 = "None"
                case 1:
                    MyVariables.switch2 = "None"
                case 2:
                    MyVariables.switch3 = "None"
                case 3:
                    MyVariables.switch4 = "None"
                case .none:
                    print("It's nil.")
                case .some(let value):
                    print("It's \(value).")
                }
                
                //歸檔
                let model = DataModelSwitch()
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: model, requiringSecureCoding: false)
                    try data.write(to: URL(fileURLWithPath: getDocumentsPath(path: "DataModelSwitch")!))
                } catch {
                    print(error)
                }
                
                recipes = RecipeSwitch.createRecipes(switch1: MyVariables.switch1,
                                                 switch2: MyVariables.switch2,
                                                 switch3: MyVariables.switch3,
                                                 switch4: MyVariables.switch4)
                
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
}

