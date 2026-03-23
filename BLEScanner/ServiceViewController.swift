////
////  ServiceView.swift
////  BLEScanner
////
////  Created by rafael_sw on 2021/4/19.
////
//
//import Foundation
//import UIKit
//import CoreBluetooth
//
//class ServiceViewController: UIViewController {
//    
//    @IBOutlet weak var deviceName: UILabel!
//    @IBOutlet weak var uuidLabel: UILabel!
//    @IBOutlet weak var tableView: UITableView!
//    
//    // 直接使用 CBPeripheral，移除 BLEFramework 依賴
//    public var peripheral: CBPeripheral!
//    public var deviceInUseUUID = ""
//    
//    private var serviceInUse: CBService!
//    private var serviceTitles: [String] = []
//    private var serviceUUIDs: [String] = []
//    private var serviceSubtitles: [String] = []
//    private var services: [CBService] = []
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "segue_service_to_characteristic" {
//            let controller = segue.destination as? CharViewController
//            // 直接傳遞 peripheral 與 serviceInUse
//            controller?.peripheral = peripheral
//            controller?.serviceInUse = serviceInUse
//        }
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        guard let services = peripheral.services else { return }
//        
//        for (index, service) in services.enumerated() {
//            self.services.append(service)
//            serviceTitles.append("服務(\(index))")
//            serviceUUIDs.append(service.uuid.uuidString)
//            serviceSubtitles.append("服務類型(主服務)")
//        }
//        
//        deviceName.text = "Device name: \(peripheral.name ?? "")"
//        uuidLabel.text = "UUID: \(deviceInUseUUID)"
//    }
//}
//
//extension ServiceViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return serviceTitles.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceTableCell", for: indexPath) as! ServiceTableCell
//        cell.serviceTitle.text = serviceTitles[indexPath.row]
//        cell.serviceUUID.text = serviceUUIDs[indexPath.row]
//        cell.serviceSubtitle.text = serviceSubtitles[indexPath.row]
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.serviceInUse = services[indexPath.row]
//        self.performSegue(withIdentifier: "segue_service_to_characteristic", sender: nil)
//    }
//}
