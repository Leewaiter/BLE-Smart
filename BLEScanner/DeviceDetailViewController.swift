//
//import UIKit
//import Foundation
//import CoreBluetooth
//
//class DeviceDetailViewController: UIViewController {
//    
//    var device: wifiRB1!
//    var centralManager: CBCentralManager!
//    
//    private let stackView = UIStackView()
//    private let titleLabel = UILabel()
//    private let nameLabel = UILabel()
//    private let rssiLabel = UILabel()
//    private let idLabel = UILabel()
//    private let stateLabel = UILabel()
//    private let connectButton = UIButton(type: .system)
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
////        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissSelf))
////        navigationItem.rightBarButtonItem = closeButton
//        setupUI()
//        updateUI()
//    }
//    
//    private func setupUI() {
//        // 垂直 StackView 簡單化佈局
//        stackView.axis = .vertical
//        stackView.spacing = 16
//        stackView.alignment = .fill
//        stackView.distribution = .fill
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(stackView)
//        
//        NSLayoutConstraint.activate([
//            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
//            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
//            stackView.widthAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.widthAnchor, constant: -32)
//        ])
//        
//        // 標題
//        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
//        titleLabel.textColor = .label
//        titleLabel.textAlignment = .center
//        titleLabel.numberOfLines = 0
//        stackView.addArrangedSubview(titleLabel)
//        
//        // 屬性標籤：用簡單 UILabel 堆疊
//        let infoLabels: [(UILabel, String)] = [
//            (nameLabel, "名稱:"),
//            (rssiLabel, "RSSI:"),
//            (idLabel, "Identifier:"),
//            (stateLabel, "狀態:")
//        ]
//        
//        for (label, prefix) in infoLabels {
//            label.font = UIFont.systemFont(ofSize: 14)
//            label.textColor = .secondaryLabel
//            label.numberOfLines = 0
//            stackView.addArrangedSubview(label)
//        }
//        
//        // 按鈕：永久顯示，根據狀態調整文字/啟用
//        connectButton.setTitle("連線", for: .normal)
//        connectButton.backgroundColor = .systemBlue
//        connectButton.setTitleColor(.white, for: .normal)
//        connectButton.layer.cornerRadius = 8
//        connectButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
//        connectButton.addTarget(self, action: #selector(connectTapped), for: .touchUpInside)
//        stackView.addArrangedSubview(connectButton)
//    }
//    
//    private func updateUI() {
//        titleLabel.text = "設備細節: \(device.name)"
//        
//        // 屬性
//        nameLabel.text = "名稱: \(device.name)"
//        rssiLabel.text = "RSSI: \(device.rssi)dBm"
//        idLabel.text = "Identifier: \(device.peripheral.identifier.uuidString)"
//        stateLabel.text = "狀態: \(getPeripheralState())"
//        
//        // 按鈕：永久顯示，但根據狀態調整（可連線時啟用）
//        switch device.peripheral.state {
//        case .disconnected:
//            connectButton.setTitle("連線", for: .normal)
//            connectButton.isEnabled = true  // 可連線，啟用
//        case .connecting:
//            connectButton.setTitle("連線中...", for: .normal)
//            connectButton.isEnabled = false  // 連線中，禁用
//        case .connected:
//            connectButton.setTitle("斷開", for: .normal)
//            connectButton.isEnabled = true  // 已連線，可斷開
//        @unknown default:
//            connectButton.setTitle("未知", for: .normal)
//            connectButton.isEnabled = false
//        }
//    }
//    
//    private func getPeripheralState() -> String {
//        switch device.peripheral.state {
//        case .disconnected:
//            return "未連線"
//        case .connecting:
//            return "連線中"
//        case .connected:
//            return "已連線"
//        @unknown default:
//            return "未知"
//        }
//    }
//    
//    @objc private func connectTapped() {
//        switch device.peripheral.state {
//        case .disconnected:
//            centralManager.connect(device.peripheral)  // 連線
//            print("開始連線: \(device.name)")
//        case .connected:
//            centralManager.cancelPeripheralConnection(device.peripheral)  // 斷開
//            print("斷開連線: \(device.name)")
//        default:
//            break  // 其他狀態不動作
//        }
//        updateUI()  // 更新按鈕狀態
//    }
//    
////    @objc private func dismissSelf() {
////        dismiss(animated: true)
////    }
//}
