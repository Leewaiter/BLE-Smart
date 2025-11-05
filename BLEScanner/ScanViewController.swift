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


struct MyVariables {
    
//    Version
    static var version = "None"
    
//    Custom name
    static var customNames = [[String]]()
    
//    group
    static var groupDeviceArrayAll = [String]()
    static var groupDeviceArray1 = [String]()
    static var groupDeviceArray2 = [String]()
    static var groupDeviceArray3 = [String]()
    static var groupDeviceArray4 = [String]()
    
    static var groupCheckboxArrayAll = [Bool]()
    static var groupCheckboxArray1 = [Bool]()
    static var groupCheckboxArray2 = [Bool]()
    static var groupCheckboxArray3 = [Bool]()
    static var groupCheckboxArray4 = [Bool]()
    
    
//    switch
    static var switchDeviceArrayAll = [String]()
    static var switchDeviceArray1 = [String]()
    static var switchDeviceArray2 = [String]()
    static var switchDeviceArray3 = [String]()
    static var switchDeviceArray4 = [String]()
    
    static var switchCheckboxArrayAll = [Bool]()
    static var switchCheckboxArray1 = [Bool]()
    static var switchCheckboxArray2 = [Bool]()
    static var switchCheckboxArray3 = [Bool]()
    static var switchCheckboxArray4 = [Bool]()
    
    static var switchInformations = [[[String]]]()
    static var switchs = [String]()
    static var switch1 = "None"
    static var switch2 = "None"
    static var switch3 = "None"
    static var switch4 = "None"
    static var switchChoose = Int()
    
//    sensor
    static var sensorDeviceArrayAll = [String]()
    static var sensorDeviceArray1 = [String]()
    static var sensorDeviceArray2 = [String]()
    static var sensorDeviceArray3 = [String]()
    static var sensorDeviceArray4 = [String]()
    
    static var sensorCheckboxArrayAll = [Bool]()
    static var sensorCheckboxArray1 = [Bool]()
    static var sensorCheckboxArray2 = [Bool]()
    static var sensorCheckboxArray3 = [Bool]()
    static var sensorCheckboxArray4 = [Bool]()
    
    static var sensorInformations = [[[String]]]()
    static var sensors = [String]()
    static var sensor1 = "None"
    static var sensor2 = "None"
    static var sensor3 = "None"
    static var sensor4 = "None"
    static var sensorChoose = Int()
    
//  wifi router
    static var RB1Info = [[[String]]]()
    static var RB1cells = [String]()
    static var RB1cell1 = "None"
    static var RB1cell2 = "None"
    static var RB1cell3 = "None"
    static var RB1cell4 = "None"
    static var RB1cellChoose = Int()
}

extension String{
    static func changeToInt(num:String) -> Int {
            let str = num.uppercased()
            var sum = 0
            for i in str.utf8 {
                sum = sum * 16 + Int(i) - 48 // 0-9 从48开始
                if i >= 65 {                 // A-Z 从65开始，但有初始值10，所以应该是减去55
                    sum -= 7
                }
            }
            return sum
     }
}

extension Data {
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
    
    var hexString : String {
            return self.reduce("") { (a : String, v : UInt8) -> String in
                return a + String(format: "%02x", v)
            }
    }
}


class ScanViewController: UIViewController, BLEFramework.BLEServiceDelegate,CBPeripheralManagerDelegate, UIGestureRecognizerDelegate, CBPeripheralDelegate{
    
    var locationManager = CLLocationManager()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var blueView: UIView!
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
    private var Connected: [Bool] = []
    private var deviceRSSI: [String] = []
    private var deviceUUIDs: [String] = []
    private var deviceInUseUUID = ""
    private var binPath = "/fota_bin"
    private var logPath = "/log"
    private var serviceDictionary = [CBService: [CBCharacteristic]]()
    private let greenColor = UIColor(red: 20/255, green: 210/255, blue: 57/255, alpha: 1)
    private let THROUGHPUT_SERVICEUUID = "00112233-4455-6677-8899-AABBCCDDEEFF"//"00005301-0000-0041-4C50-574953450000"//"00112233-4455-6677-8899-AABBCCDDEEFF"
    private let THROUGHPUT_CHARACTERISTICUUID_WRITE_AT_CMD = "50515253-5455-5657-5859-5A5B5C5D5E5F"
    private let THROUGHPUT_CHARACTERISTICUUID_WRITE =       "50515253-5455-5657-5859-5A5B5C5D5E5F"//"00005302-0000-0041-4C50-574953450000"//"50515253-5455-5657-5859-5A5B5C5D5E5F"
    private let THROUGHPUT_CHARACTERISTICUUID_NOTIFY = "FA02"//"00005303-0000-0041-4C50-574953450000"//"FA02"
    private let NEW_THROUGHPUT_CHARACTERISTICUUID_NOTIFY = "30313233-3435-3637-3839-3A3B3C3D3E3F"
    
    private let OLD_THROUGHPUT_SERVICEUUID = "00005301-0000-0041-4C50-574953450000"
    private let OLD_THROUGHPUT_CHARACTERISTICUUID_WRITE =       "00005302-0000-0041-4C50-574953450000"
    private let OLD_THROUGHPUT_CHARACTERISTICUUID_NOTIFY = "00005303-0000-0041-4C50-574953450000"
    
    private let FOTASERVICEUUID = "FEBA"
    private let FOTACHARACTERISTICUUID_WRITENORESPONSE_NOTIFY = "FA10"
    private let FOTACHARACTERISTICUUID_WRITE_INDICATE = "FA11"
    
    private let NEW_FOTASERVICEUUID = "09102132-4354-6576-8798-A9BACBDCEDFE"
    private let NEW_FOTACHARACTERISTICUUID_WRITENORESPONSE_NOTIFY = "01112131-4151-6171-8191-A1B1C1D1E1F1"
    private let NEW_FOTACHARACTERISTICUUID_WRITE_INDICATE = "02122232-4252-6272-8292-A2B2C2D2E2F2"
    
    private let Service_UUID : String = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
    private let Characteristic_UUID1: String = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"//接收(對手機來說)
    private let Characteristic_UUID2: String = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"//發送(對手機來說)
    
//    public var centralManager: CBCentralManager?
//    public var peripheral: CBPeripheral?
    
    var info: [String] = []
    var peripheralArray: [CBPeripheral] = []
    var id: [String] = []
    var major: [Int] = []
    var minor: [Int] = []
    var status: [Bool] = []
    var rssi: [Int] = []
    var selected: [Bool] = []
    var index: Int? = nil
    
    
    public func delay(by delayTime: TimeInterval, qosClass: DispatchQoS.QoSClass? = nil,_ closure: @escaping () -> Void) {
        let dispatchQueue = qosClass != nil ? DispatchQueue.global(qos: qosClass!) : .main
        dispatchQueue.asyncAfter(deadline: DispatchTime.now() + delayTime, execute: closure)
    }
    
    //ConvertStringToByteDirectly
    func stringToBytes(_ string: String) -> [UInt8]? {
        let length = string.count
        if length & 1 != 0 {
            return nil
        }
        var bytes = [UInt8]()
        bytes.reserveCapacity(length/2)
        var index = string.startIndex
        for _ in 0..<length/2 {
            let nextIndex = string.index(index, offsetBy: 2)
            if let b = UInt8(string[index..<nextIndex], radix: 16) {
                bytes.append(b)
            } else {
                return nil
            }
            index = nextIndex
        }
        return bytes
    }
    
    //PostDataToDevice
    public func postStringToTRF2(data: String){
        let TRF2_data = (data ).data(using: String.Encoding.utf8)
        print(type(of: TRF2_data!))
        print(TRF2_data! as NSData)
        print(TRF2_data!)
        
        print("write command:\(String(describing: data))")
        print(self.bleFramework.dataRateInUseWrite!)
        print(self.bleFramework.dataRateInUseNotify!)
        print(self.bleFramework.peripheralInUse!)
        self.bleFramework.peripheralInUse?.writeValue(TRF2_data!, for: self.bleFramework.dataRateInUseWrite!, type: .withResponse)
        print("poststringtrf2---")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue_scan_to_throughput" {
            let controller = segue.destination as? AppThroughput
            controller?.bleFramework = bleFramework
        } else if segue.identifier == "segue_scan_to_fota" {
            let controller = segue.destination as? AppFota
            controller?.bleFramework = bleFramework
        } else if segue.identifier == "segue_scan_to_service" {
            let controller = segue.destination as? ServiceViewController
            controller?.bleFramework = bleFramework
            controller?.deviceInUseUUID = deviceInUseUUID
        } else if segue.identifier == "segue_scan_to_zigbee" {
            let controller = segue.destination as? ZigbeeSwitchViewController
            controller?.bleFramework = bleFramework
            controller?.deviceInUseUUID = deviceInUseUUID
            controller?.charInUse = charInUse
        }
    }
    
    // refreshFunction
    @objc func getData(sender: UIButton){
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        MyVariables.switchDeviceArray1 = []
        MyVariables.switchDeviceArray2 = []
        MyVariables.switchDeviceArray3 = []
        MyVariables.switchDeviceArray4 = []
        MyVariables.switchCheckboxArray1 = []
        MyVariables.switchCheckboxArray2 = []
        MyVariables.switchCheckboxArray3 = []
        MyVariables.switchCheckboxArray4 = []
        
        MyVariables.sensorDeviceArray1 = []
        MyVariables.sensorDeviceArray2 = []
        MyVariables.sensorDeviceArray3 = []
        MyVariables.sensorDeviceArray4 = []
        MyVariables.sensorCheckboxArray1 = []
        MyVariables.sensorCheckboxArray2 = []
        MyVariables.sensorCheckboxArray3 = []
        MyVariables.sensorCheckboxArray4 = []
        
        MyVariables.groupDeviceArrayAll = []
        MyVariables.groupDeviceArray1 = []
        MyVariables.groupDeviceArray2 = []
        MyVariables.groupDeviceArray3 = []
        MyVariables.groupDeviceArray4 = []
        MyVariables.groupCheckboxArray1 = []
        MyVariables.groupCheckboxArray2 = []
        MyVariables.groupCheckboxArray3 = []
        MyVariables.groupCheckboxArray4 = []
        
        info = []
        peripheralArray = []
        id = []
        major = []
        minor = []
        status = []
        rssi = []
        selected = []
        index = nil
        
        self.lightSwitch.setImage(UIImage(named: "Power off.png"), for: .normal)
        self.lightName.text = "LIGHT_xxxx"
        self.levelValue.text = "Level：xx"
        self.colorValue.text = "Color：xx"
        self.levelSlider.value = 0
        self.colorSlider.value = 0
        
        delay(by: 1.5){ [self] in
            if rssi.count > 1{
                for i in 0...rssi.count-1{
                    if rssi[i] > -75{
                        info.insert(info[i], at: 0)
                        info.remove(at: i+1)
                        peripheralArray.insert(peripheralArray[i], at: 0)
                        peripheralArray.remove(at: i+1)
                        id.insert(id[i], at: 0)
                        id.remove(at: i+1)
                        major.insert(major[i], at: 0)
                        major.remove(at: i+1)
                        minor.insert(minor[i], at: 0)
                        minor.remove(at: i+1)
                        status.insert(status[i], at: 0)
                        status.remove(at: i+1)
                        rssi.insert(rssi[i], at: 0)
                        rssi.remove(at: i+1)
                        selected.insert(selected[i], at: 0 )
                        selected.remove(at: i+1)
                    }
                }
            }
        }
        
        tableView.reloadData()
        tableView.refreshControl!.endRefreshing()
    }
    
    @IBOutlet weak var version: UILabel!
    var tapCount = 0
    var timer: Timer?
    
    @objc func labelTapped() {
        tapCount += 1
        if tapCount == 1 {
            // 启动定时器
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(resetTapCount), userInfo: nil, repeats: false)
        } else if tapCount == 3 {
            // 停止定时器
            timer?.invalidate()
            timer = nil
            tapCount = 0 // 重置计数器
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "OccupancyController") as! OccupancyController
            present(vc, animated: true, completion: nil)
        }
    }

    @objc func resetTapCount() {
        tapCount = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MyVariables.version = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!
        version.text = MyVariables.version
        version.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        tapGesture.numberOfTapsRequired = 1
        version.addGestureRecognizer(tapGesture)
  
        bleFramework = BLEFramework()
        print(bleFramework.GetVersion())
        bleFramework.Initialize()
        let iPhoneVersion = PhoneInformation()
        bleFramework.largeMTU = iPhoneVersion.GetDeviceInfo()
        
        levelSlider.minimumValue = 1
        levelSlider.maximumValue = 100
        colorSlider.minimumValue = 0
        colorSlider.maximumValue = 100
        
        //讀檔
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: getDocumentsPath(path: "DataModelCustomName")!))
            if let model = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? DataModelCustomName{
            }
        } catch {
            print("unarchive failure in init")
        }

        //LongPressRecognizer
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ScanViewController.longPress(longPressGestureRecognizer:)))
        longPressRecognizer.minimumPressDuration = 1.0 // 1 second press
        longPressRecognizer.delegate = self
        self.view.addGestureRecognizer(longPressRecognizer)
        
        
        //PullToRefresh
        let refreshControl: UIRefreshControl!
        refreshControl = UIRefreshControl()
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        refreshControl?.attributedTitle = NSAttributedString(string: "更新資料", attributes: attributes)
        refreshControl?.tintColor = UIColor.white
        refreshControl?.addTarget(self, action: #selector(getData), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
        
        // 加入到畫面中
        self.view.addSubview(tableView)

        var timer = Timer()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(UpdateRssi), userInfo: nil, repeats: true)
        
        delay(by: 1.5){ [self] in
            if rssi.count > 1{
                for i in 0...rssi.count-1{
                    if rssi[i] > -75{
                        info.insert(info[i], at: 0)
                        info.remove(at: i+1)
                        peripheralArray.insert(peripheralArray[i], at: 0)
                        peripheralArray.remove(at: i+1)
                        id.insert(id[i], at: 0)
                        id.remove(at: i+1)
                        major.insert(major[i], at: 0)
                        major.remove(at: i+1)
                        minor.insert(minor[i], at: 0)
                        minor.remove(at: i+1)
                        status.insert(status[i], at: 0)
                        status.remove(at: i+1)
                        rssi.insert(rssi[i], at: 0)
                        rssi.remove(at: i+1)
                        selected.insert(selected[i], at: 0 )
                        selected.remove(at: i+1)
                    }
                }
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        bleFramework.RegisterBLE(self)
        UpdateBleList()
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//            super.viewWillDisappear(animated)
//        if bleFramework.isScanning == true {
//            bleFramework.stopScan()
//            }
//        }
    
    @objc func UpdateRssi()
    {
        tableView.reloadData()
    }
    
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager?
    
    @IBAction func Switch(_ sender: Any) {
        if index != nil{
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            self.peripheralManager?.stopAdvertising()
            
            var uuid = UUID(uuidString: "52455454-4c00-0000-0000-" + id[index!] + "00000000")!
            var localBeaconMajor: CLBeaconMajorValue = 100
            var localBeaconMinor: CLBeaconMinorValue = 100
            if status[index!] == true{
                uuid = UUID(uuidString: "52455454-4c00-0000-0000-" + id[index!] + "00000000")!
                localBeaconMajor = 0
                localBeaconMinor = 0
                status[index!] = false
            }else{
                uuid = UUID(uuidString: "52455454-4c00-0000-0000-" + id[index!] + "00000000")!
                localBeaconMajor = 0
                localBeaconMinor = 1
                status[index!] = true
            }

            localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
            beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
            
            peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
            print("localBeacon : \(localBeacon)\nbeaconPeripheralData : \(beaconPeripheralData)\nperipheralManager : \(peripheralManager)")
            delay(by: 1){
                self.peripheralManager?.stopAdvertising()
            }
        }
    }
    
    @IBAction func levelSlider(_ sender: UISlider) {
        if index != nil{
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            self.peripheralManager?.stopAdvertising()
            
            let uuid = UUID(uuidString: "52455454-4c00-0000-0000-" + id[index!] + "00002000")!
            let localBeaconMajor: CLBeaconMajorValue = 0
            let localBeaconMinor: CLBeaconMinorValue = CLBeaconMinorValue(Int(levelSlider.value))

            major[index!] = Int(levelSlider.value)
            levelValue.text = "Level：" + String(major[index!])
            
            localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
            beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
            
            peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
            delay(by: 1){
                self.peripheralManager?.stopAdvertising()
            }
            
            print("localBeacon : \(localBeacon)\nbeaconPeripheralData : \(beaconPeripheralData)\nperipheralManager : \(peripheralManager)")
            
        }else{
            levelValue.text = "Level：xx"
            colorValue.text = "Color：xx"
            levelSlider.value = Float(0)
            colorSlider.value = Float(0)
        }
    }
    @IBAction func colorSlider(_ sender: Any) {
        if index != nil{
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            self.peripheralManager?.stopAdvertising()
            
            let uuid = UUID(uuidString: "52455454-4c00-0000-0000-" + id[index!] + "00004000")!
            let localBeaconMajor: CLBeaconMajorValue = 0
            let localBeaconMinor: CLBeaconMinorValue = CLBeaconMinorValue(Int(colorSlider.value))

            minor[index!] = Int(colorSlider.value)
            colorValue.text = "Color：" + String(minor[index!])
            
            localBeacon = CLBeaconRegion(uuid: uuid, major:localBeaconMajor, minor:localBeaconMinor, identifier:"SSID")
            beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
            
            peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
            
            print("localBeacon : \(localBeacon)\nbeaconPeripheralData : \(beaconPeripheralData)\nperipheralManager : \(peripheralManager)")
            
            delay(by: 1){
                self.peripheralManager?.stopAdvertising()
            }
        }else{
            levelValue.text = "Level：xx"
            colorValue.text = "Color：xx"
            levelSlider.value = Float(0)
            colorSlider.value = Float(0)
        }
        
    }
    
    
    
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        self.peripheralManager?.startAdvertising(beaconPeripheralData as? [String: Any])
    }
    
    
    func UpdateBleList(){
        UpdateTable()
        for index in 0..<deviceConnected.count
        {
            if deviceConnected[index]
            {
                if !deviceStatus[index]
                {
                    Connected[index] = !Connected[index]
                    bleFramework.Disconnect(to: peripheralArray[index])
                }
            }
        }
        UpdateTable()
        tableView.reloadData()
    }
    
    private func UpdateTable()
    {
//        deviceConnected = bleFramework.GetPeripheralConnected()
//        deviceRSSI = bleFramework.GetPeripheralRSSI()
//        foundPeripherals = bleFramework.GetPeripherals()
        deviceConnected = Connected
        deviceStatus = bleFramework.GetPeripheralStatus()
        deviceUUIDs = bleFramework.GetPeripheralUUID()
        serviceDictionary = bleFramework.GetServiceDictionary()
    }
    
    
    
    //Cache Document
    func getDocumentsPath(path: String) -> String? {
        let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last as NSString?
        let filePath = docPath?.appendingPathComponent(path);
        print("文件路径的地址是\(docPath ?? "")")
        return filePath
    }
    
    func BLECentralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let peripheralname = advertisementData[CBAdvertisementDataLocalNameKey] as? String
            ?? peripheral.name
            ?? "N/A"
        
//        if advertisementData["kCBAdvDataManufacturerData"] != nil{
//            let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey]
//            print("M data: \(manufacturerData as! NSData)")
//        }
        
//        print("peripheral: \(peripheral.name ?? "N/A")\n")
        
//        if (peripheralname as NSString).length >= 9{
//            if String(peripheralname.prefix(9)) == "Bluedroid"{
//                peripheral.delegate = self
                
//                peripheralArray.append(peripheral)
//                rssi.append(Int(truncating: RSSI))
//            }
//        }
        
        if (peripheralname as NSString).length >= 12{
            if String(peripheralname.prefix(8)) == "DOOR SW_"{
                var checkDuplicates = false
                
                if !MyVariables.sensors.isEmpty {
                    for i in 0...MyVariables.sensors.count-1{
                        if peripheralname == MyVariables.sensors[i]{
                            checkDuplicates = true
                        }
                    }
                }
                if checkDuplicates == false{
                    MyVariables.sensors.append(peripheralname)
                }
            }
        }
        
        
        if (peripheralname as NSString).length >= 7{
            if String(peripheralname.prefix(7)) == "SENSOR_"{
                var checkDuplicates = false
                if !MyVariables.sensors.isEmpty {
                    for i in 0...MyVariables.sensors.count-1{
                        if peripheralname == MyVariables.sensors[i]{
                            checkDuplicates = true
                        }
                    }
                }
                
                if checkDuplicates == false{
                    MyVariables.sensors.append(peripheralname)
                }
            }
        }
        
//        if (peripheralname as NSString).length >= 10{
//            if String(peripheralname.prefix(6)) == "uWave_"{
//                var checkDuplicates = false
//                
//                if !MyVariables.sensors.isEmpty {
//                    for i in 0...MyVariables.sensors.count-1{
//                        if peripheralname == MyVariables.sensors[i]{
//                            checkDuplicates = true
//                        }
//                    }
//                }
//                if checkDuplicates == false{
//                    MyVariables.sensors.append(peripheralname)
//                }
//            }
//        }
        
        
        if (peripheralname as NSString).length >= 7{
            if String(peripheralname.prefix(3)) == "OC_"{
                var checkDuplicates = false
                
                if !MyVariables.sensors.isEmpty {
                    for i in 0...MyVariables.sensors.count-1{
                        if peripheralname == MyVariables.sensors[i]{
                            checkDuplicates = true
                        }
                    }
                }
                if checkDuplicates == false{
                    MyVariables.sensors.append(peripheralname)
                }
            }
        }
        
        if (peripheralname as NSString).length >= 7{
            if String(peripheralname.prefix(3)) == "FR_"{
                var checkDuplicates = false
                
                if !MyVariables.sensors.isEmpty {
                    for i in 0...MyVariables.sensors.count-1{
                        if peripheralname == MyVariables.sensors[i]{
                            checkDuplicates = true
                        }
                    }
                }
                if checkDuplicates == false{
                    MyVariables.sensors.append(peripheralname)
                }
            }
        }
        
        
        if (peripheralname as NSString).length >= 9{
            if String(peripheralname.prefix(3)) == "FDFR_"{
                var checkDuplicates = false
                
                if !MyVariables.sensors.isEmpty {
                    for i in 0...MyVariables.sensors.count-1{
                        if peripheralname == MyVariables.sensors[i]{
                            checkDuplicates = true
                        }
                    }
                }
                if checkDuplicates == false{
                    MyVariables.sensors.append(peripheralname)
                }
            }
        }
        
        if (peripheralname as NSString).length >= 11{
            if String(peripheralname.prefix(7)) == "SWITCH_"{
                let name = "WSW4_" + String(peripheralname.suffix(4))
                var checkDuplicates = false
                
                if !MyVariables.switchs.isEmpty {
                    for i in 0...MyVariables.switchs.count-1{
                        if name == MyVariables.switchs[i]{
                            checkDuplicates = true
                        }
                    }
                }
                if checkDuplicates == false{
                    MyVariables.switchs.append(name)
                }
            }
        }
        
        if (peripheralname as NSString).length >= 13{
            if String(peripheralname.prefix(9)) == "RELAY_SW_"{
                var checkDuplicates=false
                for element in info {
                    if (peripheralname == element){
                        checkDuplicates=true
                    }
                }
                if advertisementData["kCBAdvDataManufacturerData"] != nil{
                    let data = advertisementData["kCBAdvDataManufacturerData"]! as! Data
                    let uuid = data.hexDescription

                    if uuid.count >= 50{
                        let groupUUID = String(String(uuid.suffix(from: uuid.index(uuid.startIndex,offsetBy: 32))).prefix(upTo: uuid.index(uuid.startIndex, offsetBy: 4)))
                        let reg = "^[a-zA-Z0-9]+$"
                        let pre = NSPredicate(format: "SELF MATCHES %@", reg)
                        
                        if pre.evaluate(with: groupUUID) {
                            var groupUUIDInt = Int(String(String.changeToInt(num: groupUUID), radix: 2))!
                            var groupsTemp: [Bool] = [false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false]
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[0] = true
                            }
                            groupUUIDInt /= 10
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[1] = true
                            }
                            groupUUIDInt /= 10
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[2] = true
                            }
                            groupUUIDInt /= 10
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[3] = true
                            }
                            groupUUIDInt /= 10
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[4] = true
                            }
                            groupUUIDInt /= 10
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[5] = true
                            }
                            groupUUIDInt /= 10
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[6] = true
                            }
                            groupUUIDInt /= 10
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[7] = true
                            }
                            groupUUIDInt /= 10
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[8] = true
                            }
                            groupUUIDInt /= 10
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[9] = true
                            }
                            groupUUIDInt /= 10
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[10] = true
                            }
                            groupUUIDInt /= 10
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[11] = true
                            }
                            groupUUIDInt /= 10
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[12] = true
                            }
                            groupUUIDInt /= 10
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[13] = true
                            }
                            groupUUIDInt /= 10
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[14] = true
                            }
                            groupUUIDInt /= 10
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[15] = true
                            }
                            
                            
                            let switch_type = String(String(uuid.suffix(from: uuid.index(uuid.startIndex,offsetBy: 22))).prefix(upTo: uuid.index(uuid.startIndex, offsetBy: 2)))
                            //Switch(WSW4) Calculate
                            let switchUUID_WSW4 = String(String(uuid.suffix(from: uuid.index(uuid.startIndex,offsetBy: 24))).prefix(upTo: uuid.index(uuid.startIndex, offsetBy: 4)))
                            
                            var switchDuplicate_WSW4 = false
                            var switch_deviceDuplicate_WSW4 = false
                            
                            if !MyVariables.switchInformations.isEmpty {
                                for i in 0...MyVariables.switchInformations.count-1{
                                    if switch_type == "00" && switchUUID_WSW4 == MyVariables.switchInformations[i][0][0]{
                                        switchDuplicate_WSW4 = true
                                        if !MyVariables.switchInformations[i][1].isEmpty {
                                            for j in 0...MyVariables.switchInformations[i][1].count-1{
                                                if peripheralname == MyVariables.switchInformations[i][1][j]{
                                                    switch_deviceDuplicate_WSW4 = true
                                                }
                                            }
                                        }
                                        if switch_deviceDuplicate_WSW4 == false{
                                            MyVariables.switchInformations[i][1].append(peripheralname)
                                        }
                                        
                                        
                                    }
                                }
                            }
                            if switch_type == "00" && switchDuplicate_WSW4 == false && switchUUID_WSW4 != "0000"{
                                MyVariables.switchInformations.append([[switchUUID_WSW4],[]])
                                
                                let name = "WSW4_" + switchUUID_WSW4.uppercased()
                                var checkDuplicates = false
                                if !MyVariables.switchs.isEmpty {
                                    for i in 0...MyVariables.switchs.count-1{
                                        if name == MyVariables.switchs[i]{
                                            checkDuplicates = true
                                        }
                                    }
                                }
                                if checkDuplicates == false{
                                    MyVariables.switchs.append(name)
                                }
                            }
                            
                            //Switch(MSW4) Calculate
                            let switchUUID_MSW4 = String(String(uuid.suffix(from: uuid.index(uuid.startIndex,offsetBy: 24))).prefix(upTo: uuid.index(uuid.startIndex, offsetBy: 4)))
                            
                            var switchDuplicate_MSW4 = false
                            var switch_deviceDuplicate_MSW4 = false
                            
                            if !MyVariables.switchInformations.isEmpty {
                                for i in 0...MyVariables.switchInformations.count-1{
                                    if switch_type == "01" && switchUUID_MSW4 == MyVariables.switchInformations[i][0][0]{
                                        switchDuplicate_MSW4 = true
                                        if !MyVariables.switchInformations[i][1].isEmpty {
                                            for j in 0...MyVariables.switchInformations[i][1].count-1{
                                                if peripheralname == MyVariables.switchInformations[i][1][j]{
                                                    switch_deviceDuplicate_MSW4 = true
                                                }
                                            }
                                        }
                                        if switch_deviceDuplicate_MSW4 == false{
                                            MyVariables.switchInformations[i][1].append(peripheralname)
                                        }
                                        
                                        
                                    }
                                }
                            }
                            if switch_type == "01" && switchDuplicate_MSW4 == false && switchUUID_MSW4 != "0000"{
                                MyVariables.switchInformations.append([[switchUUID_MSW4],[]])
                                
                                let name = "MSW4_" + switchUUID_MSW4.uppercased()
                                var checkDuplicates = false
                                if !MyVariables.switchs.isEmpty {
                                    for i in 0...MyVariables.switchs.count-1{
                                        if name == MyVariables.switchs[i]{
                                            checkDuplicates = true
                                        }
                                    }
                                }
                                if checkDuplicates == false{
                                    MyVariables.switchs.append(name)
                                }
                            }
                            
                            //Sensor Calculate
                            let sensorUUID = String(String(uuid.suffix(from: uuid.index(uuid.startIndex,offsetBy: 36))).prefix(upTo: uuid.index(uuid.startIndex, offsetBy: 4)))
                            
                            var sensorDuplicate = false
                            var sensor_deviceDuplicate = false
                            
                            if !MyVariables.sensorInformations.isEmpty {
                                for i in 0...MyVariables.sensorInformations.count-1{
                                    if sensorUUID == MyVariables.sensorInformations[i][0][0]{
                                        sensorDuplicate = true
                                        if !MyVariables.sensorInformations[i][1].isEmpty {
                                            for j in 0...MyVariables.sensorInformations[i][1].count-1{
                                                if peripheralname == MyVariables.sensorInformations[i][1][j]{
                                                    sensor_deviceDuplicate = true
                                                }
                                            }
                                        }
                                        if sensor_deviceDuplicate == false{
                                            MyVariables.sensorInformations[i][1].append(peripheralname)
                                        }
                                        
                                        
                                    }
                                }
                            }
                            if sensorDuplicate == false && sensorUUID != "0000"{
                                MyVariables.sensorInformations.append([[sensorUUID],[]])
                            }
                            
                            
                            
   
                            
                            if (checkDuplicates == false){
                                MyVariables.switchDeviceArray1.append(peripheralname)
                                MyVariables.switchDeviceArray2.append(peripheralname)
                                MyVariables.switchDeviceArray3.append(peripheralname)
                                MyVariables.switchDeviceArray4.append(peripheralname)
                                MyVariables.switchCheckboxArray1.append(false)
                                MyVariables.switchCheckboxArray2.append(false)
                                MyVariables.switchCheckboxArray3.append(false)
                                MyVariables.switchCheckboxArray4.append(false)
                                
                                MyVariables.sensorDeviceArray1.append(peripheralname)
                                MyVariables.sensorDeviceArray2.append(peripheralname)
                                MyVariables.sensorDeviceArray3.append(peripheralname)
                                MyVariables.sensorDeviceArray4.append(peripheralname)
                                MyVariables.sensorCheckboxArray1.append(false)
                                MyVariables.sensorCheckboxArray2.append(false)
                                MyVariables.sensorCheckboxArray3.append(false)
                                MyVariables.sensorCheckboxArray4.append(false)
                                
                                MyVariables.groupDeviceArrayAll.append(peripheralname)
                                MyVariables.groupDeviceArray1.append(peripheralname)
                                MyVariables.groupDeviceArray2.append(peripheralname)
                                MyVariables.groupDeviceArray3.append(peripheralname)
                                MyVariables.groupDeviceArray4.append(peripheralname)
                                MyVariables.groupCheckboxArray1.append(false)
                                MyVariables.groupCheckboxArray2.append(false)
                                MyVariables.groupCheckboxArray3.append(false)
                                MyVariables.groupCheckboxArray4.append(false)
                                
                                
                                info.append(peripheralname)
                                peripheralArray.append(peripheral)
                                selected.append(false)
                                rssi.append(Int(RSSI))

                                
                                print("insert:\(peripheralname)")
                                let data = advertisementData["kCBAdvDataManufacturerData"]! as! Data
                                let uuid = data.hexDescription
                                var temp = String(uuid.suffix(from: uuid.index(uuid.startIndex,offsetBy: 40)))
                                
                                
                                
                                
                                id.append(String(peripheralname.suffix(from: peripheralname.index(peripheralname.startIndex, offsetBy: 9))))
                                let maj = Int(String(temp.prefix(upTo: temp.index(temp.startIndex,offsetBy: 4))), radix: 16)!
                                major.append(maj)
                                temp = String(temp.suffix(from: temp.index(temp.startIndex,offsetBy: 4)))
                                let min = Int(String(temp.prefix(upTo: temp.index(temp.startIndex,offsetBy: 4))), radix: 16)!
                                minor.append(min)
                                var statu = false
                                if maj == 0 && min == 0{
                                    statu = false
                                }else{
                                    statu = true
                                }
                                status.append(statu)
                                self.Connected.append(false)

                                
                                //Group Calculate
                                var temp0 = false
                                if MyVariables.groupDeviceArrayAll.count > 0{
                                    for i in 0...MyVariables.groupDeviceArrayAll.count-1{
                                        if MyVariables.groupDeviceArrayAll[i] == peripheralname{
                                            temp0 = true
                                        }
                                    }
                                }
                                if temp0 == false{
                                    MyVariables.groupDeviceArrayAll.append(peripheralname)
                                    MyVariables.groupCheckboxArrayAll.append(true)
                                    
                                }
                                
                                var temp1 = false
                                if MyVariables.groupDeviceArray1.count > 0{
                                    for i in 0...MyVariables.groupDeviceArray1.count-1{
                                        if MyVariables.groupDeviceArray1[i] == peripheralname{
                                            if groupsTemp[0] == true{
                                                MyVariables.groupCheckboxArray1[i] = true
                                            }else{
                                                MyVariables.groupCheckboxArray1[i] = false
                                            }
                                            temp1 = true
                                        }
                                    }
                                }
                                if temp1 == false{
                                    if groupsTemp[0] == true{
                                        MyVariables.groupCheckboxArray1.append(true)
                                    }else{
                                        MyVariables.groupCheckboxArray1.append(false)
                                    }
                                }
                                
                                var temp2 = false
                                if MyVariables.groupDeviceArray2.count > 0{
                                    for i in 0...MyVariables.groupDeviceArray2.count-1{
                                        if MyVariables.groupDeviceArray2[i] == peripheralname{
                                            if groupsTemp[1] == true{
                                                MyVariables.groupCheckboxArray2[i] = true
                                            }else{
                                                MyVariables.groupCheckboxArray2[i] = false
                                            }
                                            temp2 = true
                                        }
                                    }
                                }
                                if temp2 == false{
                                    if groupsTemp[1] == true{
                                        MyVariables.groupCheckboxArray2.append(true)
                                    }else{
                                        MyVariables.groupCheckboxArray2.append(false)
                                    }
                                }
                                
                                var temp3 = false
                                if MyVariables.groupDeviceArray3.count > 0{
                                    for i in 0...MyVariables.groupDeviceArray3.count-1{
                                        if MyVariables.groupDeviceArray3[i] == peripheralname{
                                            if groupsTemp[2] == true{
                                                MyVariables.groupCheckboxArray3[i] = true
                                            }else{
                                                MyVariables.groupCheckboxArray3[i] = false
                                            }
                                            temp3 = true
                                        }
                                    }
                                }
                                if temp3 == false{
                                    if groupsTemp[2] == true{
                                        MyVariables.groupCheckboxArray3.append(true)
                                    }else{
                                        MyVariables.groupCheckboxArray3.append(false)
                                    }
                                }
                                
                                var temp4 = false
                                if MyVariables.groupDeviceArray4.count > 0{
                                    for i in 0...MyVariables.groupDeviceArray4.count-1{
                                        if MyVariables.groupDeviceArray4[i] == peripheralname{
                                            if groupsTemp[3] == true{
                                                MyVariables.groupCheckboxArray4[i] = true
                                            }else{
                                                MyVariables.groupCheckboxArray4[i] = false
                                            }
                                            temp4 = true
                                        }
                                    }
                                }
                                if temp4 == false{
                                    if groupsTemp[3] == true{
                                        MyVariables.groupCheckboxArray4.append(true)
                                    }else{
                                        MyVariables.groupCheckboxArray4.append(false)
                                    }
                                }
                                
                                UpdateTable()
                                DispatchQueue.main.async(execute: {
                                    self.tableView.reloadData()
                                })
                      
                            }else{
                                if index != nil{
                                    let data = advertisementData["kCBAdvDataManufacturerData"]! as! Data
                                    let uuid = data.hexDescription
                                    var temp = String(uuid.suffix(from: uuid.index(uuid.startIndex,offsetBy: 40)))
                                    
                                    let maj = Int(String(temp.prefix(upTo: temp.index(temp.startIndex,offsetBy: 4))), radix: 16)!
                                    major[self.index!] = maj
                                    temp = String(temp.suffix(from: temp.index(temp.startIndex,offsetBy: 4)))
                                    let min = Int(String(temp.prefix(upTo: temp.index(temp.startIndex,offsetBy: 4))), radix: 16)!
                                    minor[self.index!] = min
                                    if maj == 0 && min == 0{
                                        DispatchQueue.main.async {
                                            if peripheralname == self.lightName.text{
                                                self.lightSwitch.setImage(UIImage(named: "Power off.png"), for: .normal)
                                                self.levelValue.text = "Level：xx"
                                                self.colorValue.text = "Color：xx"
                                                self.levelSlider.value = 0
                                                self.colorSlider.value = 0
                                                self.status[self.index!] = false
                                            }
                                        }
                                    }else{
                                        DispatchQueue.main.async {
                                            if peripheralname == self.lightName.text{
                                                self.lightSwitch.setImage(UIImage(named: "Power on.png"), for: .normal)
                                                self.levelValue.text = "Level：" + String(self.major[self.index!])
                                                self.colorValue.text = "Color：" + String(self.minor[self.index!])
                                                self.levelSlider.value = Float(self.major[self.index!])
                                                self.colorSlider.value = Float(self.minor[self.index!])
                                                self.status[self.index!] = true
                                            }
                                        }
                                    }
                                }
                                
                            }
                        }
                        if info.count > 0{
                            for i in 0...info.count-1{
                                if peripheralname == info[i]{
                                    rssi[i] = Int(RSSI)
                                }
                            }
                        }
                    }
                    
                }
                    
            }
                
            
        }
        
        if (peripheralname as NSString).length >= 10
        {
            if String(peripheralname.prefix(6)) == "LIGHT_"
            {
                var checkDuplicates=false
                for element in info {
                    if (peripheralname == element){
                        checkDuplicates=true
                    }
                }
                if advertisementData["kCBAdvDataManufacturerData"] != nil{
                    let data = advertisementData["kCBAdvDataManufacturerData"]! as! Data
                    let uuid = data.hexDescription

                    if uuid.count >= 50{
                        let groupUUID = String(String(uuid.suffix(from: uuid.index(uuid.startIndex,offsetBy: 32))).prefix(upTo: uuid.index(uuid.startIndex, offsetBy: 4)))
                        let reg = "^[a-zA-Z0-9]+$"
                        let pre = NSPredicate(format: "SELF MATCHES %@", reg)
                        
                        if pre.evaluate(with: groupUUID) {
                            var groupUUIDInt = Int(String(String.changeToInt(num: groupUUID), radix: 2))!
                            var groupsTemp: [Bool] = [false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false]
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[0] = true
                            }
                            groupUUIDInt /= 10
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[1] = true
                            }
                            groupUUIDInt /= 10
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[2] = true
                            }
                            groupUUIDInt /= 10
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[3] = true
                            }
                            groupUUIDInt /= 10
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[4] = true
                            }
                            groupUUIDInt /= 10
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[5] = true
                            }
                            groupUUIDInt /= 10
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[6] = true
                            }
                            groupUUIDInt /= 10
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[7] = true
                            }
                            groupUUIDInt /= 10
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[8] = true
                            }
                            groupUUIDInt /= 10
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[9] = true
                            }
                            groupUUIDInt /= 10
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[10] = true
                            }
                            groupUUIDInt /= 10
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[11] = true
                            }
                            groupUUIDInt /= 10
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[12] = true
                            }
                            groupUUIDInt /= 10
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[13] = true
                            }
                            groupUUIDInt /= 10
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[14] = true
                            }
                            groupUUIDInt /= 10
                            if groupUUIDInt % 10 == 1{
                                groupsTemp[15] = true
                            }
                            
                            
                            let switch_type = String(String(uuid.suffix(from: uuid.index(uuid.startIndex,offsetBy: 22))).prefix(upTo: uuid.index(uuid.startIndex, offsetBy: 2)))
                            //Switch(WSW4) Calculate
                            let switchUUID_WSW4 = String(String(uuid.suffix(from: uuid.index(uuid.startIndex,offsetBy: 24))).prefix(upTo: uuid.index(uuid.startIndex, offsetBy: 4)))
                            
                            var switchDuplicate_WSW4 = false
                            var switch_deviceDuplicate_WSW4 = false
                            
                            if !MyVariables.switchInformations.isEmpty {
                                for i in 0...MyVariables.switchInformations.count-1{
                                    if switch_type == "00" && switchUUID_WSW4 == MyVariables.switchInformations[i][0][0]{
                                        switchDuplicate_WSW4 = true
                                        if !MyVariables.switchInformations[i][1].isEmpty {
                                            for j in 0...MyVariables.switchInformations[i][1].count-1{
                                                if peripheralname == MyVariables.switchInformations[i][1][j]{
                                                    switch_deviceDuplicate_WSW4 = true
                                                }
                                            }
                                        }
                                        if switch_deviceDuplicate_WSW4 == false{
                                            MyVariables.switchInformations[i][1].append(peripheralname)
                                        }
                                        
                                        
                                    }
                                }
                            }
                            if switch_type == "00" && switchDuplicate_WSW4 == false && switchUUID_WSW4 != "0000"{
                                MyVariables.switchInformations.append([[switchUUID_WSW4],[]])
                                
                                let name = "WSW4_" + switchUUID_WSW4.uppercased()
                                var checkDuplicates = false
                                if !MyVariables.switchs.isEmpty {
                                    for i in 0...MyVariables.switchs.count-1{
                                        if name == MyVariables.switchs[i]{
                                            checkDuplicates = true
                                        }
                                    }
                                }
                                if checkDuplicates == false{
                                    MyVariables.switchs.append(name)
                                }
                            }
                            
                            //Switch(MSW4) Calculate
                            let switchUUID_MSW4 = String(String(uuid.suffix(from: uuid.index(uuid.startIndex,offsetBy: 24))).prefix(upTo: uuid.index(uuid.startIndex, offsetBy: 4)))
                            
                            var switchDuplicate_MSW4 = false
                            var switch_deviceDuplicate_MSW4 = false
                            
                            if !MyVariables.switchInformations.isEmpty {
                                for i in 0...MyVariables.switchInformations.count-1{
                                    if switch_type == "01" && switchUUID_MSW4 == MyVariables.switchInformations[i][0][0]{
                                        switchDuplicate_MSW4 = true
                                        if !MyVariables.switchInformations[i][1].isEmpty {
                                            for j in 0...MyVariables.switchInformations[i][1].count-1{
                                                if peripheralname == MyVariables.switchInformations[i][1][j]{
                                                    switch_deviceDuplicate_MSW4 = true
                                                }
                                            }
                                        }
                                        if switch_deviceDuplicate_MSW4 == false{
                                            MyVariables.switchInformations[i][1].append(peripheralname)
                                        }
                                        
                                        
                                    }
                                }
                            }
                            if switch_type == "01" && switchDuplicate_MSW4 == false && switchUUID_MSW4 != "0000"{
                                MyVariables.switchInformations.append([[switchUUID_MSW4],[]])
                                
                                let name = "MSW4_" + switchUUID_MSW4.uppercased()
                                var checkDuplicates = false
                                if !MyVariables.switchs.isEmpty {
                                    for i in 0...MyVariables.switchs.count-1{
                                        if name == MyVariables.switchs[i]{
                                            checkDuplicates = true
                                        }
                                    }
                                }
                                if checkDuplicates == false{
                                    MyVariables.switchs.append(name)
                                }
                            }
                            
                            
                            //Sensor Calculate
                            let sensorUUID = String(String(uuid.suffix(from: uuid.index(uuid.startIndex,offsetBy: 36))).prefix(upTo: uuid.index(uuid.startIndex, offsetBy: 4)))
                            var sensorDuplicate = false
                            var sensor_deviceDuplicate = false
                            
                            if !MyVariables.sensorInformations.isEmpty {
                                for i in 0...MyVariables.sensorInformations.count-1{
                                    if sensorUUID == MyVariables.sensorInformations[i][0][0]{
                                        sensorDuplicate = true
                                        if !MyVariables.sensorInformations[i][1].isEmpty {
                                            for j in 0...MyVariables.sensorInformations[i][1].count-1{
                                                if peripheralname == MyVariables.sensorInformations[i][1][j]{
                                                    sensor_deviceDuplicate = true
                                                }
                                            }
                                        }
                                        if sensor_deviceDuplicate == false{
                                            MyVariables.sensorInformations[i][1].append(peripheralname)
                                        }
                                        
                                        
                                    }
                                }
                            }
                            if sensorDuplicate == false && sensorUUID != "0000"{
                                MyVariables.sensorInformations.append([[sensorUUID],[]])
                            }
                            
                            
                            
                            
                            
   
                            
                            if (checkDuplicates == false){
                                MyVariables.switchDeviceArray1.append(peripheralname)
                                MyVariables.switchDeviceArray2.append(peripheralname)
                                MyVariables.switchDeviceArray3.append(peripheralname)
                                MyVariables.switchDeviceArray4.append(peripheralname)
                                MyVariables.switchCheckboxArray1.append(false)
                                MyVariables.switchCheckboxArray2.append(false)
                                MyVariables.switchCheckboxArray3.append(false)
                                MyVariables.switchCheckboxArray4.append(false)
                                
                                MyVariables.sensorDeviceArray1.append(peripheralname)
                                MyVariables.sensorDeviceArray2.append(peripheralname)
                                MyVariables.sensorDeviceArray3.append(peripheralname)
                                MyVariables.sensorDeviceArray4.append(peripheralname)
                                MyVariables.sensorCheckboxArray1.append(false)
                                MyVariables.sensorCheckboxArray2.append(false)
                                MyVariables.sensorCheckboxArray3.append(false)
                                MyVariables.sensorCheckboxArray4.append(false)
                                
                                MyVariables.groupDeviceArrayAll.append(peripheralname)
                                MyVariables.groupDeviceArray1.append(peripheralname)
                                MyVariables.groupDeviceArray2.append(peripheralname)
                                MyVariables.groupDeviceArray3.append(peripheralname)
                                MyVariables.groupDeviceArray4.append(peripheralname)
                                MyVariables.groupCheckboxArray1.append(false)
                                MyVariables.groupCheckboxArray2.append(false)
                                MyVariables.groupCheckboxArray3.append(false)
                                MyVariables.groupCheckboxArray4.append(false)
                                
                                info.append(peripheralname)
                                peripheralArray.append(peripheral)
                                selected.append(false)
                                rssi.append(Int(RSSI))

                                
                                print("insert:\(peripheralname)")
                                let data = advertisementData["kCBAdvDataManufacturerData"]! as! Data
                                let uuid = data.hexDescription
                                var temp = String(uuid.suffix(from: uuid.index(uuid.startIndex,offsetBy: 40)))
                                
                                
                                
                                
                                id.append(String(peripheralname.suffix(from: peripheralname.index(peripheralname.startIndex, offsetBy: 6))))
                                let maj = Int(String(temp.prefix(upTo: temp.index(temp.startIndex,offsetBy: 4))), radix: 16)!
                                major.append(maj)
                                temp = String(temp.suffix(from: temp.index(temp.startIndex,offsetBy: 4)))
                                let min = Int(String(temp.prefix(upTo: temp.index(temp.startIndex,offsetBy: 4))), radix: 16)!
                                minor.append(min)
                                var statu = false
                                if maj == 0 && min == 0{
                                    statu = false
                                }else{
                                    statu = true
                                }
                                status.append(statu)
                                self.Connected.append(false)

                                
                                //Group Calculate
                                var temp0 = false
                                if MyVariables.groupDeviceArrayAll.count > 0{
                                    for i in 0...MyVariables.groupDeviceArrayAll.count-1{
                                        if MyVariables.groupDeviceArrayAll[i] == peripheralname{
                                            temp0 = true
                                        }
                                    }
                                }
                                if temp0 == false{
                                    MyVariables.groupDeviceArrayAll.append(peripheralname)
                                    MyVariables.groupCheckboxArrayAll.append(true)
                                    
                                }
                                
                                var temp1 = false
                                if MyVariables.groupDeviceArray1.count > 0{
                                    for i in 0...MyVariables.groupDeviceArray1.count-1{
                                        if MyVariables.groupDeviceArray1[i] == peripheralname{
                                            if groupsTemp[0] == true{
                                                MyVariables.groupCheckboxArray1[i] = true
                                            }else{
                                                MyVariables.groupCheckboxArray1[i] = false
                                            }
                                            temp1 = true
                                        }
                                    }
                                }
                                if temp1 == false{
                                    if groupsTemp[0] == true{
                                        MyVariables.groupCheckboxArray1.append(true)
                                    }else{
                                        MyVariables.groupCheckboxArray1.append(false)
                                    }
                                }
                                
                                var temp2 = false
                                if MyVariables.groupDeviceArray2.count > 0{
                                    for i in 0...MyVariables.groupDeviceArray2.count-1{
                                        if MyVariables.groupDeviceArray2[i] == peripheralname{
                                            if groupsTemp[1] == true{
                                                MyVariables.groupCheckboxArray2[i] = true
                                            }else{
                                                MyVariables.groupCheckboxArray2[i] = false
                                            }
                                            temp2 = true
                                        }
                                    }
                                }
                                if temp2 == false{
                                    if groupsTemp[1] == true{
                                        MyVariables.groupCheckboxArray2.append(true)
                                    }else{
                                        MyVariables.groupCheckboxArray2.append(false)
                                    }
                                }
                                
                                var temp3 = false
                                if MyVariables.groupDeviceArray3.count > 0{
                                    for i in 0...MyVariables.groupDeviceArray3.count-1{
                                        if MyVariables.groupDeviceArray3[i] == peripheralname{
                                            if groupsTemp[2] == true{
                                                MyVariables.groupCheckboxArray3[i] = true
                                            }else{
                                                MyVariables.groupCheckboxArray3[i] = false
                                            }
                                            temp3 = true
                                        }
                                    }
                                }
                                if temp3 == false{
                                    if groupsTemp[2] == true{
                                        MyVariables.groupCheckboxArray3.append(true)
                                    }else{
                                        MyVariables.groupCheckboxArray3.append(false)
                                    }
                                }
                                
                                var temp4 = false
                                if MyVariables.groupDeviceArray4.count > 0{
                                    for i in 0...MyVariables.groupDeviceArray4.count-1{
                                        if MyVariables.groupDeviceArray4[i] == peripheralname{
                                            if groupsTemp[3] == true{
                                                MyVariables.groupCheckboxArray4[i] = true
                                            }else{
                                                MyVariables.groupCheckboxArray4[i] = false
                                            }
                                            temp4 = true
                                        }
                                    }
                                }
                                if temp4 == false{
                                    if groupsTemp[3] == true{
                                        MyVariables.groupCheckboxArray4.append(true)
                                    }else{
                                        MyVariables.groupCheckboxArray4.append(false)
                                    }
                                }
                                
                                UpdateTable()
                                DispatchQueue.main.async(execute: {
                                    self.tableView.reloadData()
                                })
                      
                            }else{
                                if index != nil{
                                    let data = advertisementData["kCBAdvDataManufacturerData"]! as! Data
                                    let uuid = data.hexDescription
                                    var temp = String(uuid.suffix(from: uuid.index(uuid.startIndex,offsetBy: 40)))
                                    
                                    let maj = Int(String(temp.prefix(upTo: temp.index(temp.startIndex,offsetBy: 4))), radix: 16)!
                                    major[self.index!] = maj
                                    temp = String(temp.suffix(from: temp.index(temp.startIndex,offsetBy: 4)))
                                    let min = Int(String(temp.prefix(upTo: temp.index(temp.startIndex,offsetBy: 4))), radix: 16)!
                                    minor[self.index!] = min
                                    if maj == 0 && min == 0{
                                        DispatchQueue.main.async {
                                            if peripheralname == self.lightName.text{
                                                self.lightSwitch.setImage(UIImage(named: "Power off.png"), for: .normal)
                                                self.levelValue.text = "Level：xx"
                                                self.colorValue.text = "Color：xx"
                                                self.levelSlider.value = 0
                                                self.colorSlider.value = 0
                                                self.status[self.index!] = false
                                            }
                                        }
                                    }else{
                                        DispatchQueue.main.async {
                                            if peripheralname == self.lightName.text{
                                                self.lightSwitch.setImage(UIImage(named: "Power on.png"), for: .normal)
                                                self.levelValue.text = "Level：" + String(self.major[self.index!])
                                                self.colorValue.text = "Color：" + String(self.minor[self.index!])
                                                self.levelSlider.value = Float(self.major[self.index!])
                                                self.colorSlider.value = Float(self.minor[self.index!])
                                                self.status[self.index!] = true
                                            }
                                        }
                                    }
                                }
                                
                            }
                        }
                        if info.count > 0{
                            for i in 0...info.count-1{
                                if peripheralname == info[i]{
                                    rssi[i] = Int(RSSI)
                                }
                            }
                        }
                    }
                    
                }
                    
            }
                
            
        }
    }
    
    func BLECentralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        UpdateTable()
    }
    
    func BLECentralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        DispatchQueue.main.async(execute: {
            self.UpdateBleList()
        })
    }
}

extension ScanViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return peripheralArray.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var customName = info[indexPath.row]
        for i in 0..<MyVariables.customNames.count {
            if info[indexPath.row] == MyVariables.customNames[i][0]{
                customName = MyVariables.customNames[i][1]
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScanTableCell", for: indexPath) as! ScanTableCell
        cell.deviceName.text = customName
        cell.deviceUUID.text = info[indexPath.row]
        cell.devicePower.text = String(rssi[indexPath.row]) + "dBm"
        
        
//        let peripheral = peripheralArray[indexPath.row]
//        let rssi = String(rssi[indexPath.row]) + "dBm"
//        if (cell.deviceName.text != cell.textLabel?.text){
//            cell.textLabel?.text = String(peripheral.name ?? "Unknown Device") + rssi
//        }

        if deviceConnected[indexPath.row]{
            cell.deviceName.textColor = greenColor
            cell.deviceUUID.textColor = greenColor
            cell.devicePower.textColor = greenColor
        }else if selected[indexPath.row]{
            cell.deviceName.textColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            cell.deviceUUID.textColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            cell.devicePower.textColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        }else{
            cell.deviceName.textColor = .black
            cell.deviceUUID.textColor = .black
            cell.devicePower.textColor = .black
        }
        

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        index = indexPath.row
        levelSlider.value = Float(major[index!])
        colorSlider.value = Float(minor[index!])
        
        lightName.text = peripheralArray[index!].name
        levelValue.text = "Level：" + String(major[index!])
        colorValue.text = "Color：" + String(minor[index!])
       
        
        if peripheralArray[index!].name?.prefix(9) == "RELAY_SW_"{
            levelValue.isHidden = true
            levelSlider.isHidden = true
            colorValue.isHidden = true
            colorSlider.isHidden = true
            
//            lightSwitch.topAnchor.constraint(equalTo: blueView.bottomAnchor, constant: 200).isActive = true
        }else{
            levelValue.isHidden = false
            levelSlider.isHidden = false
            colorValue.isHidden = false
            colorSlider.isHidden = false
            
//            lightSwitch.topAnchor.constraint(equalTo: blueView.bottomAnchor, constant: 500).isActive = true
        }
        
        if status[index!] == false{
            lightSwitch.setImage(UIImage(named: "Power off.png"), for: .normal)
        }else{
            lightSwitch.setImage(UIImage(named: "Power on.png"), for: .normal)
        }
        
        for i in 0...selected.count-1{
            selected[i] = false
        }
        selected[index!] = true
        tableView.reloadData()
        
    }
    
    func removeTopConstraint(from view: UIView) {
        for constraint in view.constraints {
            if let firstItem = constraint.firstItem as? UIView, firstItem == view,
               constraint.firstAttribute == .top {
                constraint.isActive = false
            }
        }
    }
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {

        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {

            let touchPoint = longPressGestureRecognizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint)?.row {
                if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
                    print("LongPress: \(indexPath)")
                    
                    var alertStyle = UIAlertController.Style.actionSheet
                    if (UIDevice.current.userInterfaceIdiom == .pad) {
                      alertStyle = UIAlertController.Style.alert
                    }
                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: alertStyle)
                    alert.addAction(UIAlertAction(title: "Rename", style: .default, handler: { _ in
                        let renameAlert = UIAlertController(title: "Rename", message: nil, preferredStyle: .alert)
                            
                        renameAlert.addTextField { textField in
                            textField.placeholder = "Leave blank to restore default."
                        }
                        
                        renameAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { [self] _ in
                            if let textField = renameAlert.textFields?.first, let customName = textField.text {

                                var settingDone = false
                                for i in 0..<MyVariables.customNames.count{
                                    if String(peripheralArray[indexPath].name!) == MyVariables.customNames[i][0]{
                                        MyVariables.customNames[i][1] = customName
                                        if customName == ""{
                                            MyVariables.customNames.remove(at: i)
                                        }
                                        settingDone = true
                                    }
                                }
                                if settingDone == false{
                                    MyVariables.customNames.append([String(peripheralArray[indexPath].name!),customName])
                                }
                                
                                //歸檔
                                let model = DataModelCustomName()
                                do {
                                    let data = try NSKeyedArchiver.archivedData(withRootObject: model, requiringSecureCoding: false)
                                    try data.write(to: URL(fileURLWithPath: getDocumentsPath(path: "DataModelCustomName")!))
                                } catch {
                                    print(error)
                                }
                                
                                tableView.reloadData()
                            }
                        }))
                        
                        renameAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        
                        self.present(renameAlert, animated: true, completion: nil)

                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

}

