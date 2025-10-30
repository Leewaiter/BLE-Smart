//
//  AppThroughput.swift
//  BLEScanner
//
//  Created by rafael_sw on 2021/4/7.
//

import Foundation
import UIKit
import CoreBluetooth
import BLEFramework

class AppThroughput: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, BLEFramework.BLEServiceDelegate {
    
    @IBOutlet weak var led: UIBarButtonItem!
    @IBOutlet weak var mtuLengthLabel: UILabel!
    @IBOutlet weak var atemtuLength: UITextField!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var mtuLength: UITextField!
    @IBOutlet weak var packetLength: UITextField!
    @IBOutlet weak var selType: UIPickerView!
    @IBOutlet weak var ateType: UIPickerView!
    @IBOutlet weak var runBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var logView: UITextView!
    
    public var bleFramework : BLEFramework!
    private var selTypeList = ["aT-dR", "aR-dT"];
    private var ateTypeList = ["No ATE", "Test All Option"]
    private var getReleaseToCTMR = false
    override func viewDidLoad() {
        super.viewDidLoad()
        bleFramework.RegisterBLE(self)
        if bleFramework.largeMTU
        {
            mtuLength.text = "244"
            atemtuLength.text = "20,244"
        } else
        {
            mtuLength.text = "160"
            atemtuLength.text = "20,160"
        }
    }
    
    func ShowProgress()
    {
        let showStatusQueue: DispatchQueue = DispatchQueue(label: "showStatus", qos: DispatchQoS.unspecified)
        showStatusQueue.async (){ ()-> Void in
            print(self.bleFramework.progress)
            while (self.bleFramework.throughput_testing)
            {
                if ((self.bleFramework.progress > 0.2) && (self.bleFramework.progressIndex == 0)) || ((self.bleFramework.progress > 0.4) && (self.bleFramework.progressIndex == 1)) ||
                    ((self.bleFramework.progress > 0.6) && (self.bleFramework.progressIndex == 2)) ||
                    ((self.bleFramework.progress > 0.8) && (self.bleFramework.progressIndex == 3)) ||
                    ((self.bleFramework.progress == 1))
                {
                    print(self.bleFramework.progress)
                    self.bleFramework.progressIndex += 1
                    DispatchQueue.main.async(execute: {
                        self.progressBar.progress = self.bleFramework.progress
                    })
                }
                if !self.bleFramework.throughput_testing
                {
                    break
                }
                sleep(2)
                if !self.bleFramework.throughput_testing
                {
                    break
                }
                sleep(2)
            }
            
            DispatchQueue.main.async(execute: {
                self.progressBar.progress = self.bleFramework.progress
            })
            
        }
    }
    
    func PopAlert(title: String, message: String, action: String){
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction.init(title: action, style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    func SetCmd()
    {
        let setCmdQueue: DispatchQueue = DispatchQueue(label: "setCmd")
        setCmdQueue.async (){ ()-> Void in
            self.bleFramework.SetCmd()
        }
    }
    
    func CheckParameterStatus()
    {
        self.view.isUserInteractionEnabled = false
        let checkStatusQueue: DispatchQueue = DispatchQueue(label: "checkStatus")
        checkStatusQueue.async (){ ()-> Void in
            while (self.bleFramework.setCmdStatus == 1)
            {
                
            }
            DispatchQueue.main.async(execute: {
                if (self.bleFramework.setCmdStatus == -1)
                {
                    self.PopAlert(title: "Error", message: "",   action: "Please set parameters again")
                } else
                {
                    self.PopAlert(title: "Successful", message: "",   action: "Done")
                }
                self.view.isUserInteractionEnabled = true
            })
        }
    }
    
    @IBAction func setParameter(_ sender: Any) {
        let alert = UIAlertController.init(title: "Set parameters", message: "", preferredStyle: .alert)

        let cancelAction = UIAlertAction.init(title: "Cancel", style: .destructive, handler: nil)
        
        let phyAction = UIAlertAction(title: "Set phy rate", style: .default, handler: { (_) in
            let phyalert = UIAlertController.init(title: "Set phy rate", message: "", preferredStyle: .alert)
            let phy1MAction = UIAlertAction(title: "1M", style: .default, handler: { (_) in
                self.bleFramework.phyRate = 1
                self.SetCmd()
                self.CheckParameterStatus()
            })
            let phy2MAction = UIAlertAction(title: "2M", style: .default, handler: { (_) in
                self.bleFramework.phyRate = 2
                self.SetCmd()
                self.CheckParameterStatus()
            })
            let phyS2Action = UIAlertAction(title: "S2", style: .default, handler: { (_) in
                self.bleFramework.phyRate = 3
                self.SetCmd()
                self.CheckParameterStatus()
            })
            let phyS8Action = UIAlertAction(title: "S8", style: .default, handler: { (_) in
                self.bleFramework.phyRate = 4
                self.SetCmd()
                self.CheckParameterStatus()
            })
            
            phyalert.addAction(phy1MAction)
            phyalert.addAction(phy2MAction)
            phyalert.addAction(phyS2Action)
            phyalert.addAction(phyS8Action)
            phyalert.addAction(cancelAction)
            self.present(phyalert, animated: true)
        })
        let intervalAction = UIAlertAction.init(title: "Set connection interval", style: .destructive, handler: { (_) in
            let intervalalert = UIAlertController.init(title: "Set connection interval", message: "", preferredStyle: .alert)
            let balanceAction = UIAlertAction(title: "(30-50ms)CONNECTION_BALANCE", style: .default, handler: { (_) in
                self.bleFramework.connectionInterval = 32
                self.SetCmd()
                self.CheckParameterStatus()
            })
            let highAction = UIAlertAction(title: "(11.25-15ms)CONNECTION_HIGH", style: .default, handler: { (_) in
                self.bleFramework.connectionInterval = 12
                self.SetCmd()
                self.CheckParameterStatus()
            })
            let lowAction = UIAlertAction(title: "(100-125ms)CONNECTION_LOW", style: .default, handler: { (_) in
                self.bleFramework.connectionInterval = 90
                self.SetCmd()
                self.CheckParameterStatus()
            })
            
            intervalalert.addAction(balanceAction)
            intervalalert.addAction(highAction)
            intervalalert.addAction(lowAction)
            intervalalert.addAction(cancelAction)
            self.present(intervalalert, animated: true)
        })
        let modeAction = UIAlertAction.init(title: "Set Mode", style: .destructive, handler: { (_) in
            let modealert = UIAlertController.init(title: "Set Mode", message: "", preferredStyle: .alert)
            let releaseAction = UIAlertAction(title: "Release Mode", style: .default, handler: { (_) in
                self.ateType.isHidden = true
                self.getReleaseToCTMR = true
                
                self.ateType.selectRow(1, inComponent: 0, animated: true)
            })
            let debugAction = UIAlertAction(title: "Debug Mode", style: .default, handler: { (_) in
                self.ateType.isHidden = false
                self.getReleaseToCTMR = false
            })
            
            modealert.addAction(releaseAction)
            modealert.addAction(debugAction)
            modealert.addAction(cancelAction)
            self.present(modealert, animated: true)
        })
        
        alert.addAction(phyAction)
        alert.addAction(intervalAction)
        alert.addAction(modeAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    @IBAction func runBtn(_ sender: Any) {
        progressBar.progress = 0
        if let length = Int(mtuLength.text!){
            var len = length
            if bleFramework.largeMTU
            {
                if length > 244
                {
                    len = 244
                    mtuLength.text = "244"
                    atemtuLength.text = "20,244"
                } else if length < 20
                {
                    len = 20
                    mtuLength.text = "20"
                    atemtuLength.text = "20,244"
                }
            } else
            {
                if length > 160
                {
                    len = 160
                    mtuLength.text = "160"
                    atemtuLength.text = "20,160"
                } else if length < 20
                {
                    len = 20
                    mtuLength.text = "20"
                    atemtuLength.text = "20,160"
                }
            }
            
            bleFramework.throughput_sel_data_length = len
            bleFramework.mtuLengthUI = mtuLength.text!
        }
        else
        {
            PopAlert(title: "Warning", message: "Invaild value : Data Length",   action: "Please enter again")
            return
        }
        
        bleFramework.atemtuLengthUI = atemtuLength.text!
        bleFramework.packetLength = bleFramework.throughput_sel_data_length

        if let length = Int(packetLength.text!){
            bleFramework.throughput_sel_packet_length = length
            if bleFramework.throughput_sel_packet_length > 1048712 {
                PopAlert(title: "Warning", message: "The maximum packet length is 1048712", action: "Please enter again")
                return
            }
        }
        else
        {
            PopAlert(title: "Warning", message: "Invaild value : Packet Length", action: "Please enter again")
            return
        }
        bleFramework.throughput_stop_test_flag = 0
        bleFramework.throughput_sel_sent_packet_interval_ms = 0
        progressBar.progress = 0
        runBtn.isHidden = true
        stopBtn.isHidden = false
        selType.isUserInteractionEnabled = false
        ateType.isUserInteractionEnabled = false
        navigationItem.hidesBackButton = true
        bleFramework.StartThroughput()
        ShowProgress()
        let runQueue: DispatchQueue = DispatchQueue(label: "run")
        runQueue.async (){ ()-> Void in
                while (self.bleFramework.throughput_testing)
                {
                    
                    if self.bleFramework.throughput_testing == false
                    {
                        break
                    }
                    sleep(2)
                    if self.bleFramework.throughput_testing == false
                    {
                        break
                    }
                    sleep(2)
                }
                DispatchQueue.main.async(execute: {
                    print(self.bleFramework.log)
                    self.logView.text = self.bleFramework.log
                    self.selType.isUserInteractionEnabled = true
                    self.ateType.isUserInteractionEnabled = true
                    self.runBtn.isHidden = false
                    self.stopBtn.isHidden = true
                    self.navigationItem.hidesBackButton = false
                })
            }
    }
    
    
    @IBAction func stopBtn(_ sender: Any) {
        bleFramework.throughput_stop_test_flag = 1
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == selType {
            return selTypeList.count
        }else if pickerView == ateType {
            return ateTypeList.count
        }else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == selType {
            return selTypeList[row]
        }else if pickerView == ateType {
            return ateTypeList[row]
        }else {
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?)->UIView {
        let label = UILabel()
        label.sizeToFit()
        label.textAlignment = .center
        if pickerView == selType {
            label.font = UIFont.systemFont(ofSize: 14)
            label.text = selTypeList[row]
            label.textColor = UIColor.black
        } else if pickerView == ateType {
            label.font = UIFont.systemFont(ofSize: 14)
            label.text = ateTypeList[row]
            label.textColor = UIColor.black
        }

        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == ateType {
            bleFramework.THROUGHPUT_AUTO_TEST_OPTION_SEL = ateType.selectedRow(inComponent: 0)
            switch bleFramework.THROUGHPUT_AUTO_TEST_OPTION_SEL{
                case 0: //NO ATE
                    bleFramework.THROUGHPUT_DO_AUTO_TEST_COMBINATION = false
                    mtuLengthLabel.text = "MTU Data length(Byte)"
                    atemtuLength.isHidden = true
                    mtuLength.isHidden = false
                case 1: //Test ALL Option
                    bleFramework.THROUGHPUT_DO_AUTO_TEST_COMBINATION = true
                    mtuLengthLabel.text = "MTU ATE option(Byte)"
                    atemtuLength.isHidden = false
                    mtuLength.isHidden = true
                case 2: //Test PHY 1M/2M Option
                    bleFramework.THROUGHPUT_DO_AUTO_TEST_COMBINATION = true
                    mtuLengthLabel.text = "MTU Data length(Byte)"
                    atemtuLength.isHidden = true
                    mtuLength.isHidden = false
                case 3: //Test ConnectInterval Option
                    bleFramework.THROUGHPUT_DO_AUTO_TEST_COMBINATION = true
                    mtuLengthLabel.text = "MTU Data length(Byte)"
                    atemtuLength.isHidden = true
                    mtuLength.isHidden = false
                case 4: //Test MTU Length Option
                    bleFramework.THROUGHPUT_DO_AUTO_TEST_COMBINATION = true
                    mtuLengthLabel.text = "MTU ATE option(Byte)"
                    atemtuLength.isHidden = false
                    mtuLength.isHidden = true
                case 5: //Repeat test  same option
                    bleFramework.THROUGHPUT_DO_AUTO_TEST_COMBINATION = false
                    mtuLengthLabel.text = "MTU Data length(Byte)"
                    atemtuLength.isHidden = true
                    mtuLength.isHidden = false
                default:
                    bleFramework.THROUGHPUT_DO_AUTO_TEST_COMBINATION = true
                    mtuLengthLabel.text = "MTU Data length(Byte)"
                    atemtuLength.isHidden = true
                    mtuLength.isHidden = false
            }
        }else if pickerView == selType {
            bleFramework.throughput_sel_test_type = selType.selectedRow(inComponent: 0)
        }
    }
    
    func BLECentralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == bleFramework.peripheralInUse
        {
            let connectQueue: DispatchQueue = DispatchQueue(label: "connect")
            connectQueue.async (){ ()-> Void in
                sleep(1)
                self.bleFramework.SetNotify(to: peripheral, characteristic: self.bleFramework.dataRateInUseNotify, enabled: true)
                DispatchQueue.main.async(execute: {
                    self.led.tintColor = .systemGreen
                    self.view.isUserInteractionEnabled = true
                })
            }
        }
    }
    
    func BLECentralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == bleFramework.peripheralInUse
        {
            DispatchQueue.main.async(execute: {
                self.led.tintColor = .darkGray
                self.view.isUserInteractionEnabled = false
            })
            bleFramework.throughput_stop_test_flag = 1
            bleFramework.Disconnect(to: bleFramework.peripheralInUse)
            bleFramework.Connect(to: bleFramework.peripheralInUse)
        }
    }
    
    func BLECentralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
    }
}
