//
//  ServiceView.swift
//  BLEScanner
//
//  Created by rafael_sw on 2021/4/19.
//

import Foundation
import UIKit
import CoreBluetooth
import BLEFramework

class ServiceViewController: UIViewController {
    
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!    
    public var bleFramework : BLEFramework!
    public var deviceInUseUUID = ""
    private var serviceInUse: CBService!
    private var serviceTitles: [String] = []
    private var serviceUUIDs: [String] = []
    private var serviceSubtitles: [String] = []
    private var services: [CBService] = []
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue_service_to_characteristic" {
            let controller = segue.destination as? CharViewController
            controller?.bleFramework = bleFramework
            controller?.serviceInUse = serviceInUse
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var index = 0
        for service in bleFramework.peripheralInUse.services! {
            services.append(service)
            serviceTitles.append("服務(\(index))")
            serviceUUIDs.append(service.uuid.uuidString)
            serviceSubtitles.append("服務類型(主服務)")
            index += 1
        }
        deviceName.text = "Device name: \(bleFramework.peripheralInUse.name ?? "")"
        uuidLabel.text = "UUID: \(deviceInUseUUID)"
    }
}

extension ServiceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceTableCell", for: indexPath) as! ServiceTableCell
        cell.serviceTitle.text = serviceTitles[indexPath.row]
        cell.serviceUUID.text = serviceUUIDs[indexPath.row]
        cell.serviceSubtitle.text = serviceSubtitles[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.serviceInUse = services[indexPath.row]
        self.performSegue(withIdentifier: "segue_service_to_characteristic", sender: nil)
    }
}
