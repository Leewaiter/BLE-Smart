//
//  TRF2Controller.swift
//  JS18020
//
//  Created by benson on 2018/7/12.
//  Copyright © 2018年 wuhao. All rights reserved.
//

import UIKit
import SwiftUI
import SwiftMQTT


class OccupancyController: UIViewController, UIDocumentPickerDelegate, UIScrollViewDelegate, MQTTSessionDelegate{

    @IBOutlet weak var topic1: UILabel!
    @IBOutlet weak var topic2: UITextField!
    @IBOutlet weak var registerFace: UIButton!
    @IBOutlet weak var unRegisterFace: UIButton!
    @IBOutlet weak var unRegisterFaceAll: UIButton!
    @IBOutlet weak var faceCount: UILabel!
    @IBOutlet weak var macAddressTemp1: UIButton!
    @IBOutlet weak var macAddressTemp2: UIButton!
    @IBOutlet weak var macAddressTemp3: UIButton!
    
    func mqttDidAcknowledgePing(from session: SwiftMQTT.MQTTSession) {
        
    }
    
    func mqttDidDisconnect(session: SwiftMQTT.MQTTSession, error: SwiftMQTT.MQTTSessionError) {
        
    }
    
    func mqttDidReceive(message: MQTTMessage, from session: MQTTSession) {
        faceCount.text = message.stringRepresentation!
    }
    
    let mqttSession = MQTTSession(
        host: "27.105.113.156",
        port: 1883,
        clientID: "swift", // must be unique to the client
        cleanSession: true,
        keepAlive: 15,
        useSSL: false
    )
    
    var customTabBarView: UIView!
    var viewControllers: [UIViewController] = []
    var currentViewController: UIViewController?
    
    //FirstLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let value1 = UserDefaults.standard.string(forKey: "value1") {
            macAddressTemp1.setTitle(value1, for: .normal)
        }
        if let value2 = UserDefaults.standard.string(forKey: "value2") {
            macAddressTemp2.setTitle(value2, for: .normal)
        }
        if let value3 = UserDefaults.standard.string(forKey: "value3") {
            macAddressTemp3.setTitle(value3, for: .normal)
        }
        
        mqttSession.delegate = self
        
        mqttSession.username = "test"
        mqttSession.password = "test123"
        
        mqttSession.connect { error in
            if error == .none {
                print("Connected!")
            } else {
                print(error.description)
            }
        }
        
        // Create a custom tab bar view
        let height: CGFloat = 50
        customTabBarView = UIView(frame: CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: height))
        customTabBarView.backgroundColor = .white

        // Add the custom tab bar view to the main view
        view.addSubview(customTabBarView)

        // Ensure view controllers are set
        setupViewControllers()

        // Add buttons to the custom tab bar view
        let numberOfTabs = viewControllers.count
        let buttonWidth = view.frame.width / CGFloat(numberOfTabs)

        for index in 0..<numberOfTabs {
            let button = UIButton(frame: CGRect(x: CGFloat(index) * buttonWidth, y: 0, width: buttonWidth, height: height))
            button.tag = index
            button.setTitle("Tab \(index + 1)", for: .normal)
            button.setTitleColor(.blue, for: .normal)
            button.addTarget(self, action: #selector(tabBarButtonTapped(_:)), for: .touchUpInside)
            customTabBarView.addSubview(button)
        }

        // Display the first view controller by default
        displayViewController(atIndex: 0)
    
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        mqttSession.disconnect()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func setupViewControllers() {
        // Get the storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Instantiate view controllers using their storyboard IDs
        guard let vc1 = storyboard.instantiateViewController(withIdentifier: "OccupancyController") as? UIViewController,
              let vc2 = storyboard.instantiateViewController(withIdentifier: "ResetController") as? UIViewController else {
            return
        }

        // Set up your view controllers here
        viewControllers = [vc1, vc2]
    }

    @objc func tabBarButtonTapped(_ sender: UIButton) {
        displayViewController(atIndex: sender.tag)
    }

    func displayViewController(atIndex index: Int) {
        // Remove the current view controller
        if let currentViewController = currentViewController {
            currentViewController.willMove(toParent: nil)
            currentViewController.view.removeFromSuperview()
            currentViewController.removeFromParent()
        }

        // Add the new view controller
        let selectedViewController = viewControllers[index]
        addChild(selectedViewController)
        selectedViewController.view.frame = CGRect(x: 0, y: customTabBarView.frame.maxY, width: view.frame.width, height: view.frame.height - customTabBarView.frame.maxY)
        view.addSubview(selectedViewController.view)
        selectedViewController.didMove(toParent: self)

        // Set the current view controller
        currentViewController = selectedViewController
    }
    
    func saveMacAddressToTemp(){
        let temp1 = macAddressTemp1.title(for: .normal)!
        let temp2 = macAddressTemp2.title(for: .normal)!
        let temp3 = macAddressTemp3.title(for: .normal)!
        
        if topic2.text! != temp1 && topic2.text! != temp2 && topic2.text! != temp3{
            UserDefaults.standard.set(topic2.text!, forKey: "value1")
            macAddressTemp1.setTitle(topic2.text!, for: .normal)
            UserDefaults.standard.set(temp1, forKey: "value2")
            macAddressTemp2.setTitle(temp1, for: .normal)
            UserDefaults.standard.set(temp2, forKey: "value3")
            macAddressTemp3.setTitle(temp2, for: .normal)
        }
    }
    
    @IBAction func temp1(_ sender: Any) {
        let temp1 = macAddressTemp1.title(for: .normal)!
        topic2.text = temp1
    }
    @IBAction func temp2(_ sender: Any) {
        let temp2 = macAddressTemp2.title(for: .normal)!
        topic2.text = temp2
    }
    @IBAction func temp3(_ sender: Any) {
        let temp3 = macAddressTemp3.title(for: .normal)!
        topic2.text = temp3
    }
    
    @IBAction func updateFaceCount(_ sender: Any) {
//        publish
        let json = ["set" : 30]
        let data = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        let topic = topic1.text! + topic2.text!

        mqttSession.publish(data, in: topic, delivering: .atLeastOnce, retain: false) { error in
            if error == .none {
                print("Published data in \(topic)!")
            } else {
                print(error.description)
            }
        }
//        subscribe
        let topicSubscribe = topic1.text! + topic2.text! + "/total"
        mqttSession.subscribe(to: topicSubscribe, delivering: .atLeastOnce) { error in
            if error == .none {
                print("Subscribed to \(topic)!")
            } else {
                print(error.description)
            }
        }
        
        saveMacAddressToTemp()
    }
    
    @IBAction func registerFace(_ sender: Any) {
        let json = ["set" : 27]
        let data = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        let topic = topic1.text! + topic2.text!

        mqttSession.publish(data, in: topic, delivering: .atLeastOnce, retain: false) { error in
            if error == .none {
                print("Published data in \(topic)!")
            } else {
                print(error.description)
            }
        }
        
        saveMacAddressToTemp()
    }
    
    @IBAction func unRegisterFace(_ sender: Any) {
        let json = ["set" : 28]
        let data = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        let topic = topic1.text! + topic2.text!

        mqttSession.publish(data, in: topic, delivering: .atLeastOnce, retain: false) { error in
            if error == .none {
                print("Published data in \(topic)!")
            } else {
                print(error.description)
            }
        }
        
        saveMacAddressToTemp()
    }
    
    @IBAction func unRegisterFaceAll(_ sender: Any) {
        let json = ["set" : 29]
        let data = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        let topic = topic1.text! + topic2.text!

        mqttSession.publish(data, in: topic, delivering: .atLeastOnce, retain: false) { error in
            if error == .none {
                print("Published data in \(topic)!")
            } else {
                print(error.description)
            }
        }
        
        saveMacAddressToTemp()
    }
    
}
