
import UIKit

class ViewController: UITableViewController {
    
    
    static let EMPATICA_API_KEY = "Enter API key here"
    
    var username:String = ""
    var server:String = ""
    var DeviceID:String = ""
    var APIKey:String = ""
    var activityID: Int = 0
    var continueSending: Bool = true
    
    struct activityStatus: Decodable {
        let activity_id: Int
        let errors: Array<Int>
        let success: Bool
    }
    
    struct postStatus: Decodable {
        let continuebool: Bool
        let errors: Array<Int>
        let success: Bool
    }
    
    
    
    private var devices: [EmpaticaDeviceManager] = []
    
    
    private var allDisconnected : Bool {
        
        return self.devices.reduce(true) { (value, device) -> Bool in
        
            value && device.deviceStatus == kDeviceStatusDisconnected
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.delegate = self
        
        self.tableView.dataSource = self
        
        
        if self.checkActivity() == 0 {
            startActivity()
        }
        
        
        
        
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            
            EmpaticaAPI.authenticate(withAPIKey: ViewController.EMPATICA_API_KEY) { (status, message) in
                
                if status {
                    
                    
                    
                    DispatchQueue.main.async {
                        
                        self.discover()
                    }
                }
            }
        }
    }
    
    
    private func checkActivity()-> Int {
        
        guard let url = URL(string: "https://" + server + "/api/v1/activity/status") else {return 2}
        var activityIsRunning: Int = 0
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(username, forHTTPHeaderField: "USER-ID")
        request.addValue(APIKey, forHTTPHeaderField: "API-KEY")
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                do {
                    let handledData: activityStatus = try JSONDecoder().decode(activityStatus.self, from: data)
                    if handledData.activity_id != 0 {
                        activityIsRunning = 1
                        self.activityID = handledData.activity_id
                    }
                    if handledData.success != true {
                        DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                            self.stopActivity()
                        }
                    }
                    print(handledData.activity_id)
                } catch {
                    print(error)
                }
            }
        }.resume()
        
        return activityIsRunning
    }
    
    private func startActivity() {
        
        let parameters = ["device_id": DeviceID, "action": "start"]
        
        guard let url = URL(string: "https://" + server + "/api/v1/activity/control") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(username, forHTTPHeaderField: "USER-ID")
        request.addValue(APIKey, forHTTPHeaderField: "API-KEY")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return}
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let handledData: activityStatus = try JSONDecoder().decode(activityStatus.self, from: data)
                    print(handledData.activity_id)
                    self.activityID = handledData.activity_id
                } catch {
                    print(error)
                }
            }
        }.resume()
        
    }
    
    private func stopActivity() {
        
        let parameters = ["device_id": DeviceID, "action": "stop"]
        
        guard let url = URL(string: "https://" + server + "/api/v1/activity/control") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(username, forHTTPHeaderField: "USER-ID")
        request.addValue(APIKey, forHTTPHeaderField: "API-KEY")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return}
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let handledData: activityStatus = try JSONDecoder().decode(activityStatus.self, from: data)
                    print(handledData.activity_id)
                } catch {
                    print(error)
                }
            }
        }.resume()
        
    }
    
    private func discover() {
        EmpaticaAPI.discoverDevices(with: self)
    }
    
    private func disconnect(device: EmpaticaDeviceManager) {
        
        if device.deviceStatus == kDeviceStatusConnected {
            
            device.disconnect()
        }
        else if device.deviceStatus == kDeviceStatusConnecting {
            
            device.cancelConnection()
        }
    }
    
    private func connect(device: EmpaticaDeviceManager) {
        
        device.connect(with: self)
        
    }
    
    private func updateValue(device : EmpaticaDeviceManager, string : String = "") {
        
        if let row = self.devices.firstIndex(of: device) {
            
            DispatchQueue.main.async {
                
                for cell in self.tableView.visibleCells {
                    
                    if let cell = cell as? DeviceTableViewCell {
                        
                        if cell.device == device {
                            
                            let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0))
                            
                            if !device.allowed {
                                
                                cell?.detailTextLabel?.text = "NOT ALLOWED"
                                
                                cell?.detailTextLabel?.textColor = UIColor.orange
                            }
                            else if string.count > 0 {
                                
                                cell?.detailTextLabel?.text = "\(self.deviceStatusDisplay(status: device.deviceStatus)) • \(string)"
                                
                                cell?.detailTextLabel?.textColor = UIColor.gray
                            }
                            else {
                                
                                cell?.detailTextLabel?.text = "\(self.deviceStatusDisplay(status: device.deviceStatus))"
                                
                                cell?.detailTextLabel?.textColor = UIColor.gray
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func deviceStatusDisplay(status : DeviceStatus) -> String {
        
        switch status {
            
        case kDeviceStatusDisconnected:
            return "Disconnected"
        case kDeviceStatusConnecting:
            return "Connecting..."
        case kDeviceStatusConnected:
            return "Connected"
        case kDeviceStatusFailedToConnect:
            return "Failed to connect"
        case kDeviceStatusDisconnecting:
            return "Disconnecting..."
        default:
            return "Unknown"
        }
    }
    
    private func restartDiscovery() {
        
        print("restartDiscovery")
        
        guard EmpaticaAPI.status() == kBLEStatusReady else { return }
        
        if self.allDisconnected {
            
            print("restartDiscovery • allDisconnected")
            
            self.discover()
        }
    }
}


extension ViewController: EmpaticaDelegate {
    
    func didDiscoverDevices(_ devices: [Any]!) {
        
        print("didDiscoverDevices")
        
        if self.allDisconnected {
            
            print("didDiscoverDevices • allDisconnected")
            
            self.devices.removeAll()
            
            self.devices.append(contentsOf: devices as! [EmpaticaDeviceManager])
            
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
                
                if self.allDisconnected {
                
                    EmpaticaAPI.discoverDevices(with: self)
                }
            }
        }
    }
    
    func didUpdate(_ status: BLEStatus) {
        
        switch status {
        case kBLEStatusReady:
            print("[didUpdate] status \(status.rawValue) • kBLEStatusReady")
            break
        case kBLEStatusScanning:
            print("[didUpdate] status \(status.rawValue) • kBLEStatusScanning")
            break
        case kBLEStatusNotAvailable:
            print("[didUpdate] status \(status.rawValue) • kBLEStatusNotAvailable")
            break
        default:
            print("[didUpdate] status \(status.rawValue)")
        }
    }
}

extension ViewController: EmpaticaDeviceDelegate {
    
    func didReceiveTemperature(_ temp: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        
        if self.continueSending == true {
            
            let parameters = ["Temperature": String(temp), "Timestamp": String(timestamp)]
            guard let url = URL(string: "https://" + server + "/api/v1/data/in") else {return}
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(username, forHTTPHeaderField: "USER-ID")
            request.addValue(APIKey, forHTTPHeaderField: "API-KEY")
            request.addValue(DeviceID, forHTTPHeaderField: "DEVICE-ID")
            request.addValue(String(activityID), forHTTPHeaderField: "ACTIVITY-ID")
            request.addValue("Temperature", forHTTPHeaderField: "TYPE")
            
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return}
            request.httpBody = httpBody
            
            let session = URLSession.shared
            session.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    do {
                        let handledData: postStatus = try JSONDecoder().decode(postStatus.self, from: data)
                        print(handledData.continuebool)
                        if handledData.continuebool == false {
                            self.continueSending = false
                        }
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
        
    }
    
    func didReceiveAccelerationX(_ x: Int8, y: Int8, z: Int8, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        if self.continueSending == true {
            
            let parameters = ["Acceleration": "{x: \(x) y: \(y) z: \(z)}", "Timestamp": String(timestamp)]
            guard let url = URL(string: "https://" + server + "/api/v1/data/in") else {return}
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(username, forHTTPHeaderField: "USER-ID")
            request.addValue(APIKey, forHTTPHeaderField: "API-KEY")
            request.addValue(DeviceID, forHTTPHeaderField: "DEVICE-ID")
            request.addValue(String(activityID), forHTTPHeaderField: "ACTIVITY-ID")
            request.addValue("Acceleration", forHTTPHeaderField: "TYPE")
            
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return}
            request.httpBody = httpBody
            
            let session = URLSession.shared
            session.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    do {
                        let handledData: postStatus = try JSONDecoder().decode(postStatus.self, from: data)
                        print(handledData.continuebool)
                        if handledData.continuebool == false {
                            self.continueSending = false
                        }
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
        
    }
    
    
    func didReceiveGSR(_ gsr: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        
        if self.continueSending == true {
            
            let parameters = ["GSR": String(gsr), "Timestamp": String(timestamp)]
            guard let url = URL(string: "https://" + server + "/api/v1/data/in") else {return}
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(username, forHTTPHeaderField: "USER-ID")
            request.addValue(APIKey, forHTTPHeaderField: "API-KEY")
            request.addValue(DeviceID, forHTTPHeaderField: "DEVICE-ID")
            request.addValue(String(activityID), forHTTPHeaderField: "ACTIVITY-ID")
            request.addValue("Galvanic skin response", forHTTPHeaderField: "TYPE")
            
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return}
            request.httpBody = httpBody
            
            let session = URLSession.shared
            session.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    do {
                        let handledData: postStatus = try JSONDecoder().decode(postStatus.self, from: data)
                        print(handledData.continuebool)
                        if handledData.continuebool == false {
                            self.continueSending = false
                        }
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
        
        
        
        
       
    }
    
    func didReceiveHR(_ hr: Float, andQualityIndex qualityIndex: Int32, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        
        if self.continueSending == true {
            
            let parameters = ["Heartrate": String(hr), "Timestamp": String(timestamp)]
            guard let url = URL(string: "https://" + server + "/api/v1/data/in") else {return}
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(username, forHTTPHeaderField: "USER-ID")
            request.addValue(APIKey, forHTTPHeaderField: "API-KEY")
            request.addValue(DeviceID, forHTTPHeaderField: "DEVICE-ID")
            request.addValue(String(activityID), forHTTPHeaderField: "ACTIVITY-ID")
            request.addValue("Heartrate", forHTTPHeaderField: "TYPE")
            
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return}
            request.httpBody = httpBody
            
            let session = URLSession.shared
            session.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    do {
                        let handledData: postStatus = try JSONDecoder().decode(postStatus.self, from: data)
                        print(handledData.continuebool)
                        if handledData.continuebool == false {
                            self.continueSending = false
                        }
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
        
        
        
        
    }
    
    func didReceiveBVP(_ bvp: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        
        if self.continueSending == true {
            
            let parameters = ["Blood Volume Pulse": String(bvp), "Timestamp": String(timestamp)]
            guard let url = URL(string: "https://" + server + "/api/v1/data/in") else {return}
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(username, forHTTPHeaderField: "USER-ID")
            request.addValue(APIKey, forHTTPHeaderField: "API-KEY")
            request.addValue(DeviceID, forHTTPHeaderField: "DEVICE-ID")
            request.addValue(String(activityID), forHTTPHeaderField: "ACTIVITY-ID")
            request.addValue("Blood Volume Pulse", forHTTPHeaderField: "TYPE")
            
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return}
            request.httpBody = httpBody
            
            let session = URLSession.shared
            session.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    do {
                        let handledData: postStatus = try JSONDecoder().decode(postStatus.self, from: data)
                        print(handledData.continuebool)
                        if handledData.continuebool == false {
                            self.continueSending = false
                        }
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
        
    }
    
    func didReceiveIBI(_ ibi: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        
        if self.continueSending == true {
            
            let parameters = ["Interbeat Interval": String(ibi), "Timestamp": String(timestamp)]
            guard let url = URL(string: "https://" + server + "/api/v1/data/in") else {return}
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(username, forHTTPHeaderField: "USER-ID")
            request.addValue(APIKey, forHTTPHeaderField: "API-KEY")
            request.addValue(DeviceID, forHTTPHeaderField: "DEVICE-ID")
            request.addValue(String(activityID), forHTTPHeaderField: "ACTIVITY-ID")
            request.addValue("Interbeat Interval", forHTTPHeaderField: "TYPE")
            
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return}
            request.httpBody = httpBody
            
            let session = URLSession.shared
            session.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    do {
                        let handledData: postStatus = try JSONDecoder().decode(postStatus.self, from: data)
                        print(handledData.continuebool)
                        if handledData.continuebool == false {
                            self.continueSending = false
                        }
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
        
         
    }
    
    func didUpdate( _ status: DeviceStatus, forDevice device: EmpaticaDeviceManager!) {
        
        self.updateValue(device: device)
        
        switch status {
            
        case kDeviceStatusDisconnected:
            
            print("[didUpdate] Disconnected \(device.serialNumber!).")
            
            self.restartDiscovery()
            
            break
            
        case kDeviceStatusConnecting:
            
            print("[didUpdate] Connecting \(device.serialNumber!).")
            break
            
        case kDeviceStatusConnected:
            
            print("[didUpdate] Connected \(device.serialNumber!).")
            break
            
        case kDeviceStatusFailedToConnect:
            
            print("[didUpdate] Failed to connect \(device.serialNumber!).")
            
            self.restartDiscovery()
            
            break
            
        case kDeviceStatusDisconnecting:
            
            print("[didUpdate] Disconnecting \(device.serialNumber!).")
            
            break
            
        default:
            break
            
        }
    }
}

extension ViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        EmpaticaAPI.cancelDiscovery()
        
        let device = self.devices[indexPath.row]
        
        if device.deviceStatus == kDeviceStatusConnected || device.deviceStatus == kDeviceStatusConnecting {
            
            self.disconnect(device: device)
            stopActivity()
        }
        else if !device.isFaulty && device.allowed {
            
            self.connect(device: device)
            
            
        }
        
        self.updateValue(device: device)
        
    }
}

extension ViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.devices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let device = self.devices[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "device") as? DeviceTableViewCell ?? DeviceTableViewCell(device: device)
        
        cell.device = device
        
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        cell.textLabel?.text = "E4 \(device.serialNumber!)"
        
        cell.alpha = device.isFaulty || !device.allowed ? 0.2 : 1.0
        
        return cell
    }
}

class DeviceTableViewCell : UITableViewCell {
    
    
    var device : EmpaticaDeviceManager
    
    
    init(device: EmpaticaDeviceManager) {
        
        self.device = device
        
        super.init(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "device")
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}
