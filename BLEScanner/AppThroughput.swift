////
////  AppThroughput.swift
////  BLEScanner
////
////  Created by rafael_sw on 2021/4/7.
////
//
//import Foundation
//import UIKit
//import CoreBluetooth
//
//class AppThroughput: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CBCentralManagerDelegate, CBPeripheralDelegate {
//    
//    @IBOutlet weak var led: UIBarButtonItem!
//    @IBOutlet weak var mtuLengthLabel: UILabel!
//    @IBOutlet weak var atemtuLength: UITextField!
//    @IBOutlet weak var progressBar: UIProgressView!
//    @IBOutlet weak var mtuLength: UITextField!
//    @IBOutlet weak var packetLength: UITextField!
//    @IBOutlet weak var selType: UIPickerView!
//    @IBOutlet weak var ateType: UIPickerView!
//    @IBOutlet weak var runBtn: UIButton!
//    @IBOutlet weak var stopBtn: UIButton!
//    @IBOutlet weak var logView: UITextView!
//    
//    // BLE properties
//    public var centralManager: CBCentralManager?
//    public var peripheralInUse: CBPeripheral?
//    public var dataRateInUseNotify: CBCharacteristic?
//    public var dataRateInUseWrite: CBCharacteristic?
//    
//    // Throughput test properties
//    private var selTypeList = ["aT-dR", "aR-dT"]
//    private var ateTypeList = ["No ATE", "Test All Option"]
//    private var getReleaseToCTMR = false
//    private var largeMTU = false
//    private var throughput_testing = false
//    private var throughput_stop_test_flag = 0
//    private var progress: Float = 0.0
//    private var progressIndex = 0
//    private var log = ""
//    
//    // Test parameters
//    private var phyRate = 1
//    private var connectionInterval = 32
//    private var throughput_sel_data_length = 244
//    private var throughput_sel_packet_length = 1000
//    private var throughput_sel_test_type = 0
//    private var THROUGHPUT_AUTO_TEST_OPTION_SEL = 0
//    private var THROUGHPUT_DO_AUTO_TEST_COMBINATION = false
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Detect device capabilities
//        largeMTU = detectLargeMTU()
//        
//        if largeMTU {
//            mtuLength.text = "244"
//            atemtuLength.text = "20,244"
//        } else {
//            mtuLength.text = "160"
//            atemtuLength.text = "20,160"
//        }
//    }
//    
//    private func detectLargeMTU() -> Bool {
//        // Simple device detection - you may want to enhance this
//        let modelName = UIDevice.current.model
//        return modelName.contains("iPad") || modelName.contains("iPhone")
//    }
//    
//    func ShowProgress()
//    {
//        let showStatusQueue: DispatchQueue = DispatchQueue(label: "showStatus", qos: DispatchQoS.unspecified)
//        showStatusQueue.async { [weak self] in
//            guard let self = self else { return }
//            print(self.progress)
//            while self.throughput_testing {
//                if ((self.progress > 0.2) && (self.progressIndex == 0)) || 
//                   ((self.progress > 0.4) && (self.progressIndex == 1)) ||
//                   ((self.progress > 0.6) && (self.progressIndex == 2)) ||
//                   ((self.progress > 0.8) && (self.progressIndex == 3)) ||
//                   (self.progress == 1) {
//                    print(self.progress)
//                    self.progressIndex += 1
//                    DispatchQueue.main.async {
//                        self.progressBar.progress = self.progress
//                    }
//                }
//                if !self.throughput_testing { break }
//                sleep(2)
//                if !self.throughput_testing { break }
//                sleep(2)
//            }
//            
//            DispatchQueue.main.async {
//                self.progressBar.progress = self.progress
//            }
//        }
//    }
//    
//    func PopAlert(title: String, message: String, action: String){
//        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
//        let action = UIAlertAction.init(title: action, style: .default, handler: nil)
//        alert.addAction(action)
//        self.present(alert, animated: true)
//    }
//    
//    func SetCmd()
//    {
//        let setCmdQueue: DispatchQueue = DispatchQueue(label: "setCmd")
//        setCmdQueue.async { [weak self] in
//            // TODO: Implement SetCmd functionality
//            // This would send commands to the peripheral to set PHY rate, connection interval, etc.
//            print("SetCmd called - needs implementation")
//        }
//    }
//    
//    func CheckParameterStatus()
//    {
//        self.view.isUserInteractionEnabled = false
//        let checkStatusQueue: DispatchQueue = DispatchQueue(label: "checkStatus")
//        checkStatusQueue.async { [weak self] in
//            guard let self = self else { return }
//            // Simplified status checking
//            sleep(1)
//            DispatchQueue.main.async {
//                self.PopAlert(title: "Info", message: "Parameter setting requires full BLE implementation", action: "OK")
//                self.view.isUserInteractionEnabled = true
//            }
//        }
//    }
//    
//    @IBAction func setParameter(_ sender: Any) {
//        let alert = UIAlertController.init(title: "Set parameters", message: "", preferredStyle: .alert)
//
//        let cancelAction = UIAlertAction.init(title: "Cancel", style: .destructive, handler: nil)
//        
//        let phyAction = UIAlertAction(title: "Set phy rate", style: .default, handler: { (_) in
//            let phyalert = UIAlertController.init(title: "Set phy rate", message: "", preferredStyle: .alert)
//            let phy1MAction = UIAlertAction(title: "1M", style: .default, handler: { (_) in
//                self.phyRate = 1
//                self.SetCmd()
//                self.CheckParameterStatus()
//            })
//            let phy2MAction = UIAlertAction(title: "2M", style: .default, handler: { (_) in
//                self.phyRate = 2
//                self.SetCmd()
//                self.CheckParameterStatus()
//            })
//            let phyS2Action = UIAlertAction(title: "S2", style: .default, handler: { (_) in
//                self.phyRate = 3
//                self.SetCmd()
//                self.CheckParameterStatus()
//            })
//            let phyS8Action = UIAlertAction(title: "S8", style: .default, handler: { (_) in
//                self.phyRate = 4
//                self.SetCmd()
//                self.CheckParameterStatus()
//            })
//            
//            phyalert.addAction(phy1MAction)
//            phyalert.addAction(phy2MAction)
//            phyalert.addAction(phyS2Action)
//            phyalert.addAction(phyS8Action)
//            phyalert.addAction(cancelAction)
//            self.present(phyalert, animated: true)
//        })
//        let intervalAction = UIAlertAction.init(title: "Set connection interval", style: .destructive, handler: { (_) in
//            let intervalalert = UIAlertController.init(title: "Set connection interval", message: "", preferredStyle: .alert)
//            let balanceAction = UIAlertAction(title: "(30-50ms)CONNECTION_BALANCE", style: .default, handler: { (_) in
//                self.connectionInterval = 32
//                self.SetCmd()
//                self.CheckParameterStatus()
//            })
//            let highAction = UIAlertAction(title: "(11.25-15ms)CONNECTION_HIGH", style: .default, handler: { (_) in
//                self.connectionInterval = 12
//                self.SetCmd()
//                self.CheckParameterStatus()
//            })
//            let lowAction = UIAlertAction(title: "(100-125ms)CONNECTION_LOW", style: .default, handler: { (_) in
//                self.connectionInterval = 90
//                self.SetCmd()
//                self.CheckParameterStatus()
//            })
//            
//            intervalalert.addAction(balanceAction)
//            intervalalert.addAction(highAction)
//            intervalalert.addAction(lowAction)
//            intervalalert.addAction(cancelAction)
//            self.present(intervalalert, animated: true)
//        })
//        let modeAction = UIAlertAction.init(title: "Set Mode", style: .destructive, handler: { (_) in
//            let modealert = UIAlertController.init(title: "Set Mode", message: "", preferredStyle: .alert)
//            let releaseAction = UIAlertAction(title: "Release Mode", style: .default, handler: { (_) in
//                self.ateType.isHidden = true
//                self.getReleaseToCTMR = true
//                
//                self.ateType.selectRow(1, inComponent: 0, animated: true)
//            })
//            let debugAction = UIAlertAction(title: "Debug Mode", style: .default, handler: { (_) in
//                self.ateType.isHidden = false
//                self.getReleaseToCTMR = false
//            })
//            
//            modealert.addAction(releaseAction)
//            modealert.addAction(debugAction)
//            modealert.addAction(cancelAction)
//            self.present(modealert, animated: true)
//        })
//        
//        alert.addAction(phyAction)
//        alert.addAction(intervalAction)
//        alert.addAction(modeAction)
//        alert.addAction(cancelAction)
//        self.present(alert, animated: true)
//    }
//    
//    @IBAction func runBtn(_ sender: Any) {
//        progressBar.progress = 0
//        if let length = Int(mtuLength.text!){
//            var len = length
//            if largeMTU {
//                if length > 244 {
//                    len = 244
//                    mtuLength.text = "244"
//                    atemtuLength.text = "20,244"
//                } else if length < 20 {
//                    len = 20
//                    mtuLength.text = "20"
//                    atemtuLength.text = "20,244"
//                }
//            } else {
//                if length > 160 {
//                    len = 160
//                    mtuLength.text = "160"
//                    atemtuLength.text = "20,160"
//                } else if length < 20 {
//                    len = 20
//                    mtuLength.text = "20"
//                    atemtuLength.text = "20,160"
//                }
//            }
//            
//            throughput_sel_data_length = len
//        }
//        else {
//            PopAlert(title: "Warning", message: "Invaild value : Data Length",   action: "Please enter again")
//            return
//        }
//
//        if let length = Int(packetLength.text!){
//            throughput_sel_packet_length = length
//            if throughput_sel_packet_length > 1048712 {
//                PopAlert(title: "Warning", message: "The maximum packet length is 1048712", action: "Please enter again")
//                return
//            }
//        }
//        else {
//            PopAlert(title: "Warning", message: "Invaild value : Packet Length", action: "Please enter again")
//            return
//        }
//        
//        throughput_stop_test_flag = 0
//        progressBar.progress = 0
//        runBtn.isHidden = true
//        stopBtn.isHidden = false
//        selType.isUserInteractionEnabled = false
//        ateType.isUserInteractionEnabled = false
//        navigationItem.hidesBackButton = true
//        
//        // Start throughput test
//        StartThroughput()
//        ShowProgress()
//        
//        let runQueue: DispatchQueue = DispatchQueue(label: "run")
//        runQueue.async { [weak self] in
//            guard let self = self else { return }
//            while self.throughput_testing {
//                if !self.throughput_testing { break }
//                sleep(2)
//                if !self.throughput_testing { break }
//                sleep(2)
//            }
//            DispatchQueue.main.async {
//                print(self.log)
//                self.logView.text = self.log
//                self.selType.isUserInteractionEnabled = true
//                self.ateType.isUserInteractionEnabled = true
//                self.runBtn.isHidden = false
//                self.stopBtn.isHidden = true
//                self.navigationItem.hidesBackButton = false
//            }
//        }
//    }
//    
//    private func StartThroughput() {
//        // TODO: Implement actual throughput test
//        // This would involve sending data via BLE and measuring throughput
//        throughput_testing = true
//        log = "Throughput test started...\n"
//        
//        // Simulate a test for now
//        DispatchQueue.global().async { [weak self] in
//            guard let self = self else { return }
//            for i in 0...10 {
//                if self.throughput_stop_test_flag == 1 { break }
//                self.progress = Float(i) / 10.0
//                sleep(1)
//            }
//            self.throughput_testing = false
//            self.log += "Throughput test completed.\n"
//        }
//    }
//    
//    @IBAction func stopBtn(_ sender: Any) {
//        throughput_stop_test_flag = 1
//    }
//    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
//    }
//    
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        if pickerView == selType {
//            return selTypeList.count
//        }else if pickerView == ateType {
//            return ateTypeList.count
//        }else {
//            return 0
//        }
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        if pickerView == selType {
//            return selTypeList[row]
//        }else if pickerView == ateType {
//            return ateTypeList[row]
//        }else {
//            return ""
//        }
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?)->UIView {
//        let label = UILabel()
//        label.sizeToFit()
//        label.textAlignment = .center
//        if pickerView == selType {
//            label.font = UIFont.systemFont(ofSize: 14)
//            label.text = selTypeList[row]
//            label.textColor = UIColor.black
//        } else if pickerView == ateType {
//            label.font = UIFont.systemFont(ofSize: 14)
//            label.text = ateTypeList[row]
//            label.textColor = UIColor.black
//        }
//
//        return label
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        if pickerView == ateType {
//            THROUGHPUT_AUTO_TEST_OPTION_SEL = ateType.selectedRow(inComponent: 0)
//            switch THROUGHPUT_AUTO_TEST_OPTION_SEL {
//                case 0: //NO ATE
//                    THROUGHPUT_DO_AUTO_TEST_COMBINATION = false
//                    mtuLengthLabel.text = "MTU Data length(Byte)"
//                    atemtuLength.isHidden = true
//                    mtuLength.isHidden = false
//                case 1: //Test ALL Option
//                    THROUGHPUT_DO_AUTO_TEST_COMBINATION = true
//                    mtuLengthLabel.text = "MTU ATE option(Byte)"
//                    atemtuLength.isHidden = false
//                    mtuLength.isHidden = true
//                case 2: //Test PHY 1M/2M Option
//                    THROUGHPUT_DO_AUTO_TEST_COMBINATION = true
//                    mtuLengthLabel.text = "MTU Data length(Byte)"
//                    atemtuLength.isHidden = true
//                    mtuLength.isHidden = false
//                case 3: //Test ConnectInterval Option
//                    THROUGHPUT_DO_AUTO_TEST_COMBINATION = true
//                    mtuLengthLabel.text = "MTU Data length(Byte)"
//                    atemtuLength.isHidden = true
//                    mtuLength.isHidden = false
//                case 4: //Test MTU Length Option
//                    THROUGHPUT_DO_AUTO_TEST_COMBINATION = true
//                    mtuLengthLabel.text = "MTU ATE option(Byte)"
//                    atemtuLength.isHidden = false
//                    mtuLength.isHidden = true
//                case 5: //Repeat test  same option
//                    THROUGHPUT_DO_AUTO_TEST_COMBINATION = false
//                    mtuLengthLabel.text = "MTU Data length(Byte)"
//                    atemtuLength.isHidden = true
//                    mtuLength.isHidden = false
//                default:
//                    THROUGHPUT_DO_AUTO_TEST_COMBINATION = true
//                    mtuLengthLabel.text = "MTU Data length(Byte)"
//                    atemtuLength.isHidden = true
//                    mtuLength.isHidden = false
//            }
//        } else if pickerView == selType {
//            throughput_sel_test_type = selType.selectedRow(inComponent: 0)
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
//        if peripheral == peripheralInUse {
//            let connectQueue: DispatchQueue = DispatchQueue(label: "connect")
//            connectQueue.async { [weak self] in
//                guard let self = self else { return }
//                sleep(1)
//                if let char = self.dataRateInUseNotify {
//                    peripheral.setNotifyValue(true, for: char)
//                }
//                DispatchQueue.main.async {
//                    self.led.tintColor = .systemGreen
//                    self.view.isUserInteractionEnabled = true
//                }
//            }
//        }
//    }
//    
//    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
//        if peripheral == peripheralInUse {
//            DispatchQueue.main.async {
//                self.led.tintColor = .darkGray
//                self.view.isUserInteractionEnabled = false
//            }
//            throughput_stop_test_flag = 1
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
//
