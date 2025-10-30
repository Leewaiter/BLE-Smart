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



class SwitchScanViewController: UIViewController, UIGestureRecognizerDelegate, CBPeripheralManagerDelegate{
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
    var index = Int()
    var selectedRows = [IndexPath]()
    var selectId = Int()
    var timerUpdate = Timer()
    
    
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
        
        
        timerUpdate = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(reloadData), userInfo: nil, repeats: true)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    @objc func reloadData() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
    }
   
}

extension SwitchScanViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        let recipes = RecipeSwitchScan.createRecipes()
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableCell") as? SwitchTableCell {
            let recipesSwitchScan = RecipeSwitchScan.createRecipes()
            cell.configurateTheCellSwitchScan(recipesSwitchScan[indexPath.row])
            cell.selectionStyle = .none
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        if MyVariables.switchChoose == 0{
            MyVariables.switch1 = MyVariables.switchs[indexPath.row]
        }else if MyVariables.switchChoose == 1{
            MyVariables.switch2 = MyVariables.switchs[indexPath.row]
        }else if MyVariables.switchChoose == 2{
            MyVariables.switch3 = MyVariables.switchs[indexPath.row]
        }else if MyVariables.switchChoose == 3{
            MyVariables.switch4 = MyVariables.switchs[indexPath.row]
        }

        //歸檔
        let model = DataModelSwitch()
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: model, requiringSecureCoding: false)
            try data.write(to: URL(fileURLWithPath: getDocumentsPath(path: "DataModelSwitch")!))
        } catch {
            print(error)
        }
        

        tableView.reloadData()
        
        //讀檔
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: getDocumentsPath(path: "DataModelSwitch")!))
            if let model = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? DataModelSwitch{
            }
        } catch {
            print("unarchive failure in init")
        }
     
        timerUpdate.invalidate()
        dismiss(animated: true)
    }
    
    
    
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = longPressGestureRecognizer.location(in: tableView)
            index = tableView.indexPathForRow(at: touchPoint)!.row
            print("LongPress:" + String(Int(index)))
            
        }
    }
    
    
}

