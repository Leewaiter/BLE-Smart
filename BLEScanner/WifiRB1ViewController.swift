import Foundation
import UIKit
import CoreBluetooth

struct wifiRB1: Equatable {
    let peripheral: CBPeripheral
    var rssi: NSNumber
    let name: String
    let isConnectable: Bool
    var isSelected: Bool = false
}

class WifiRB1ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var centralManager: CBCentralManager!
    var devices: [wifiRB1] = []
    var TVindexPath : Int! = 0
    
    @IBOutlet weak var version: UILabel!
    @IBOutlet weak var wifiRouterTV: UITableView!
    
    var isUpdatingRSSI = true
    private var lastUpdateTimes: [UUID: Date] = [:]
    
    
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let nameLabel = UILabel()
    private let rssiLabel = UILabel()
    private let idLabel = UILabel()
    private let stateLabel = UILabel()
    private let connectButton = UIButton(type: .system)
    
    //anime
    private let waitingLabel = UILabel()
    private var waitingTimer: Timer?
    private var dotCount = 0
    private var isRefreshing = false
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        wifiRouterTV.dataSource = self
        wifiRouterTV.delegate = self
        
        wifiRouterTV.allowsSelection = true
        wifiRouterTV.allowsMultipleSelection = false
        
        setupUI()
        stackView.isHidden = true
        
        refreshControl.addTarget(self, action: #selector(refreshDevices), for: .valueChanged)
        wifiRouterTV.refreshControl = refreshControl
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if !isRefreshing {
            if centralManager?.isScanning == true {
                centralManager.stopScan()
            }
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if isRefreshing {
                print("下拉結束：等待刷新完成")
                // 不重啟掃描，等 valueChanged 結束
            } else {
                // 一般滾動結束，重啟掃描
                if centralManager?.state == .poweredOn {
                    centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
                }
            }
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        version.text = MyVariables.version
        if centralManager == nil {
            centralManager = CBCentralManager(delegate: self, queue: nil)
        }
        
        centralManagerDidUpdateState(centralManager)
        
        if devices.isEmpty {
            showWaitingAnimation()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if centralManager?.isScanning == true {
            centralManager.stopScan()
        }
        
    }
    
    // MARK: - waiting anime
    private func showWaitingAnimation() {
        stackView.isHidden = false
        waitingLabel.isHidden = false
        titleLabel.isHidden = true
        nameLabel.isHidden = true
        rssiLabel.isHidden = true
        idLabel.isHidden = true
        stateLabel.isHidden = true
        connectButton.isHidden = true
        
        dotCount = 0
        updateWaitingText()
        waitingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.dotCount = (self.dotCount + 1) % 4
            self.updateWaitingText()
        }
    }
    
    private func updateWaitingText() {
        waitingLabel.text = "waiting\(String(repeating: ".", count: dotCount))..."
    }
    
    private func stopWaitingAnimation() {
        waitingTimer?.invalidate()
        waitingTimer = nil
        waitingLabel.isHidden = true
    }
    
    @objc private func refreshDevices() {
        
        centralManager.stopScan()
        isRefreshing = true
       
        devices.removeAll()
        wifiRouterTV.reloadData()
        wifiRouterTV.refreshControl?.endRefreshing()
        
        showWaitingAnimation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [unowned self] in
            
            if centralManager.state == .poweredOn {
                refreshControl.endRefreshing()
                centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
                isRefreshing = false
            }
        }
    }
    
    //MARK: - setup, update UI
    private func setupUI() {
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
        
        waitingLabel.font = UIFont.systemFont(ofSize: 32)
        waitingLabel.textColor = .secondaryLabel
        waitingLabel.textAlignment = .center
        waitingLabel.text = "waiting..."
        waitingLabel.numberOfLines = 1
        stackView.addArrangedSubview(waitingLabel)
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        stackView.addArrangedSubview(titleLabel)
        
        let infoLabels: [(UILabel, String)] = [
            (nameLabel, "名稱:"),
            (rssiLabel, "RSSI:"),
            (idLabel, "Identifier:"),
            (stateLabel, "狀態:"),
        ]
        
        for (label, _) in infoLabels {
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = .secondaryLabel
            label.numberOfLines = 0
            stackView.addArrangedSubview(label)
        }
        
        // 按鈕：永久顯示，根據狀態調整文字/啟用/顏色
        connectButton.setTitle("連線", for: .normal)
        connectButton.backgroundColor = .systemBlue
        connectButton.setTitleColor(.white, for: .normal)
        connectButton.layer.cornerRadius = 8
        connectButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        connectButton.addTarget(self, action: #selector(connectTapped), for: .touchUpInside)
        stackView.addArrangedSubview(connectButton)
        
    }
    
    private func updateUI() {
        guard let index = TVindexPath, index < devices.count else {
//            print("無效索引，隱藏面板")
            stackView.isHidden = true
            return
        }
        
        let selectedDevice = devices[index]
        
        titleLabel.text = "設備細節: \(selectedDevice.name)"
        nameLabel.text = "名稱: \(selectedDevice.name)"
        rssiLabel.text = "RSSI: \(selectedDevice.rssi)dBm"
        idLabel.text = "Identifier: \(selectedDevice.peripheral.identifier.uuidString)"
        stateLabel.text = "狀態: \(getPeripheralState())"
        
        stackView.isHidden = false
                
        waitingLabel.isHidden = true
        titleLabel.isHidden = false
        nameLabel.isHidden = false
        rssiLabel.isHidden = false
        idLabel.isHidden = false
        stateLabel.isHidden = false
        connectButton.isHidden = false
        
        let peripheralState = selectedDevice.peripheral.state
        
        if !selectedDevice.isConnectable {
            connectButton.setTitle("不可連線", for: .normal)
            connectButton.backgroundColor = .systemGray
            connectButton.setTitleColor(.white, for: .normal)
            connectButton.isEnabled = false
            connectButton.isUserInteractionEnabled = false
        } else {
            switch peripheralState {
            case .disconnected:
                connectButton.setTitle("連線", for: .normal)
                connectButton.backgroundColor = .systemBlue
                connectButton.setTitleColor(.white, for: .normal)
                connectButton.isEnabled = true
                connectButton.isUserInteractionEnabled = true
            case .connecting:
                connectButton.setTitle("取消連線", for: .normal)
                connectButton.backgroundColor = .systemBlue
                connectButton.setTitleColor(.white, for: .normal)
                connectButton.isEnabled = true
                connectButton.isUserInteractionEnabled = true
            case .connected:
                connectButton.setTitle("斷開", for: .normal)
                connectButton.backgroundColor = .systemRed
                connectButton.setTitleColor(.white, for: .normal)
                connectButton.isEnabled = true
                connectButton.isUserInteractionEnabled = true
            @unknown default:
                connectButton.setTitle("未知", for: .normal)
                connectButton.backgroundColor = .systemGray
                connectButton.setTitleColor(.white, for: .normal)
                connectButton.isEnabled = false
                connectButton.isUserInteractionEnabled = false
            }
        }
        
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("藍牙開啟，開始掃描...")
            central.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        case .poweredOff:
            print("藍牙未開啟 - 請開啟藍牙")
        case .unauthorized:
            print("無藍牙權限 - 檢查設定 > 隱私 > 藍牙")
        default:
            print("藍牙狀態: \(central.state)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        //緩衝等待重整UI
        guard !isRefreshing else { return }
        guard let name = peripheral.name, name.hasPrefix("B") else { return }
        
        
        let now = Date()
        //避免頻繁更新RSSI, 目前設定為0.5秒一次
        if let lastTime = lastUpdateTimes[peripheral.identifier], now.timeIntervalSince(lastTime) < 0.5 {
            return
        }
        lastUpdateTimes[peripheral.identifier] = now
        
        let deviceName = peripheral.name ?? "Unknow Device:\(peripheral.identifier.uuidString.utf8)"
        let isConnectable = advertisementData[CBAdvertisementDataIsConnectable] as? Bool ?? false
        let newDevice = wifiRB1(peripheral: peripheral, rssi: RSSI, name: deviceName, isConnectable: isConnectable, isSelected: false)
        
        if let index = devices.firstIndex(where: { $0.peripheral.identifier == peripheral.identifier }) {
            if isUpdatingRSSI {
                devices[index].rssi = RSSI
                let indexPath = IndexPath(row: index, section: 0)
                wifiRouterTV.reloadRows(at: [indexPath], with: .none)
            }
        } else {
            devices.append(newDevice)
            let newIndexPath = IndexPath(row: devices.count - 1, section: 0)
            wifiRouterTV.insertRows(at: [newIndexPath], with: .fade)
        }
        
        if devices.count == 1 {
            stopWaitingAnimation()
        }
        
    }
    
    private func getSignalImage(forRSSI rssi: Double) -> UIImage? {
        let absRSSI = abs(rssi)
        if absRSSI <= 50 {
            return UIImage(named: "signal4") // 強訊號
        } else if absRSSI <= 60 {
            return UIImage(named: "signal3") // 中等訊號
        } else if absRSSI <= 70 {
            return UIImage(named: "signal2") // 次中訊號
        } else if absRSSI <= 126 {
            return UIImage(named: "signal1") // 弱訊號
        } else {
            return UIImage(named: "signal0") // 無訊號,未知訊號
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let device = devices[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: WifiRB1TableViewCell.identifier, for: indexPath) as! WifiRB1TableViewCell
        
        cell.contentView.backgroundColor = device.isSelected ? .systemBlue.withAlphaComponent(0.5) : .white
        
//        guard let cell = cell else {
//            // Fallback：預設 cell
//            let fallbackCell = UITableViewCell(style: .default, reuseIdentifier: "fallback")
//            fallbackCell.textLabel?.text = device.name
//            fallbackCell.imageView?.image = UIImage(systemName: "wifi.router.fill")
//            return fallbackCell
//        }
        
        cell.deviceName.text = device.name
        cell.icon.image =  UIImage(systemName: "wifi.router.fill")
        cell.dBm.text = "\(device.rssi)dBm"
        cell.dBm.textColor = .lightGray
        if device.isSelected {
            cell.dBm.textColor = .black
        }
        cell.dBm.font = .systemFont(ofSize: 12)
        
        let signalImage = getSignalImage(forRSSI: Double(device.rssi.intValue))
        cell.dBmImage.image = signalImage
        
//        cell.selectionStyle = .blue
//        let selectedView = UIView()
//        selectedView.backgroundColor = UIColor.systemBlue
//        cell.selectedBackgroundView = selectedView
//        let selectedView = UIView()
//        selectedView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.5)
//        selectedBackgroundView = selectedView
//        print("selectionStyle: \(cell.selectionStyle)")
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let device = devices[indexPath.row]
        TVindexPath = indexPath.row
        
        isUpdatingRSSI = false
        
        titleLabel.text = "設備細節: \(device.name)"
        nameLabel.text = "名稱: \(device.name)"
        rssiLabel.text = "RSSI: \(device.rssi)dBm"
        idLabel.text = "Identifier: \(device.peripheral.identifier.uuidString)"
        stateLabel.text = "狀態: \(getPeripheralState())"
        
        for i in 0..<devices.count {
            devices[i].isSelected = (i == indexPath.row)
        }
        
        if devices.count != 0 {
            updateUI()
            stackView.isHidden = false
        }
        
//        for i in 0..<devices.count {
//            if i != indexPath.row {
//                if let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) {
//                    if i == indexPath.row {
//                        cell.isSelected = true
//                    } else {
//                        cell.isSelected = false
//                        cell.accessoryType = .none
//                        tableView.deselectRow(at: IndexPath(row: i, section: 0), animated: false)
//                    }
//                }
//            }
//        }
        
        tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isUpdatingRSSI = true
        }
//        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        if let cell = tableView.cellForRow(at: indexPath) {
//            cell.accessoryType = .none
//        }
//    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45.0
    }
    
    @objc private func connectTapped() {
        // 檢查設備是否存在
        centralManager.stopScan()
        guard TVindexPath < devices.count else { return }
        let selectedDevice = devices[TVindexPath]
        
        guard selectedDevice.isConnectable else {
            print("設備不可連線")
            return
        }
        
        switch selectedDevice.peripheral.state {
        case .disconnected:
            centralManager.connect(selectedDevice.peripheral)
            print("開始連線: \(selectedDevice.name)")
        case .connected:
            centralManager.cancelPeripheralConnection(selectedDevice.peripheral)
            print("斷開連線: \(selectedDevice.name)")
        case .connecting:
            centralManager.cancelPeripheralConnection(selectedDevice.peripheral)
            print("連線中，取消連線")
        default:
            break;
        }
        updateUI()
        
        
    }
    
    private func getPeripheralState() -> String {
        // 檢查設備是否存在
        guard TVindexPath < devices.count else { return "未知" }
        
        switch devices[TVindexPath].peripheral.state {
        case .disconnected:
            return "未連線"
        case .connecting:
            return "連線中"
        case .connected:
            return "已連線"
        @unknown default:
            return "未知"
        }
    }
    
    // MARK: - CBPeripheralDelegate (監聽連線狀態變化，自動更新 UI)
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("連線成功: \(peripheral.name ?? "未知")")
        if TVindexPath != nil && TVindexPath < devices.count && devices[TVindexPath].peripheral.identifier == peripheral.identifier {
            updateUI()
        }
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("連線失敗: \(error?.localizedDescription ?? "未知錯誤")")
        if TVindexPath != nil && TVindexPath < devices.count && devices[TVindexPath].peripheral.identifier == peripheral.identifier {
            updateUI()
        }
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("斷開連線: \(peripheral.name ?? "未知")")
        if TVindexPath != nil && TVindexPath < devices.count && devices[TVindexPath].peripheral.identifier == peripheral.identifier {
            updateUI()
        }
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
}

class WifiRB1TableViewCell: UITableViewCell{
    
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var dBm: UILabel!
    @IBOutlet weak var dBmImage: UIImageView!
    
    static let identifier = "WifiRB1TableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
//        selectionStyle = .blue
//        let selectedView = UIView()
//        selectedView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.5)
//        selectedBackgroundView = selectedView
       
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
//        selectionStyle = .blue
//        let selectedView = UIView()
//        selectedView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.5)
//        selectedBackgroundView = selectedView
        
    }
    
}
