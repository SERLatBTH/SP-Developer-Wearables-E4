

import UIKit

class ManagerViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var textFieldDomain: UITextField!
    @IBOutlet weak var textFieldUser: UITextField!
    @IBOutlet weak var textFieldAPI: UITextField!
    @IBOutlet weak var textFieldDeviceID: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textFieldDomain.delegate = self
        self.textFieldUser.delegate = self
        self.textFieldAPI.delegate = self
        self.textFieldDeviceID.delegate = self
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ViewController
        {
            let vc = segue.destination as? ViewController
            vc?.username = textFieldUser.text ?? "no data"
            vc?.server = textFieldDomain.text ?? "no server"
            vc?.APIKey = textFieldAPI.text ?? "No API"
            vc?.DeviceID = textFieldDeviceID.text ?? "No ID"
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func startActivity(_ sender: Any) {
        
        guard let url = URL(string: "https://" + (textFieldDomain.text ?? " ") + "/api/v1/activity/status") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(textFieldUser.text ?? " ", forHTTPHeaderField: "USER-ID")
        request.addValue(textFieldAPI.text ?? " ", forHTTPHeaderField: "API-KEY")
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "SegueToDevice", sender: self)
                    }
                }
            }
            
            
            
        }.resume()
        
            
    }


}

