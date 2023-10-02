//
//  AuthxSignIn.swift
//  AuthxConfiguration
//
//  Created by Admin on 19.11.2022.
//

import Foundation
import AppKit

class AuthxSignIn: NSWindowController {
    
    var sAppID:String = ""
    var sAppKey:String = ""
    var sAppURL:String=""
    var sMainUserID:String=""
    var sUsername:String=""
    var sPassword:String=""
    
    var nRFID:Int32!
    var timer: Timer?
    var bTResult=false
    var sRFID:String!="0"
    
    @IBOutlet weak var txtUsername: NSTextField!
    @IBOutlet weak var txtPassword: NSTextField!
    @IBOutlet weak var txtPin: NSTextField!
    
    @IBOutlet weak var tabPassword: NSTabView!
   // @IBOutlet weak var tabPin: NSTabView!
    @IBOutlet weak var tabRFID: NSTabView!
    
    
    var guid = NSUUID().uuidString.lowercased()
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.center()
        self.window?.makeKeyAndOrderFront(self)
        load_app_setting()
        tabPassword.window?.update()
     //   tabPin.isHidden=true
        //sMainUserID = getUserID(userName: "Administrator")
    }
    
    func load_app_setting() -> Void{
    
        let fileURL = NSURL(string: "file:///Users/Shared/authx_security.ini")
        
        //writing
        do {
            let fileContent = try String(contentsOf: fileURL! as URL, encoding: .utf8)
            
            fileContent.enumerateLines { line, _ in
                let cols = line.components(separatedBy: ",")
                if (!cols[0].isEmpty)
                {
                    self.sAppID=cols[0]
                }
                if (!cols[1].isEmpty)
                {
                    self.sAppKey=cols[1]
                }
                if (!cols[2].isEmpty)
                {
                    self.sAppURL=cols[2]
                }
                if (!cols[3].isEmpty)
                {
                    self.sUsername=cols[3]
    
                }
                if (!cols[4].isEmpty)
                {
                    self.sPassword=cols[4]
                }
            }
        }
        catch {/* error handling here */}
    }
    
    func dialogOKCancel(question: String, text: String) -> Void {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = NSAlert.Style.critical
        alert.addButton(withTitle: "ok")
        alert.runModal()
    }
    
    func getUserID(userName:String) -> String {
        var sUserID:String=""
        let APIUrl = sAppURL + "/Login/LoginAsync"
        let url = URL(string: APIUrl)
        //let guid = NSUUID().uuidString.lowercased()
        guard let requestUrl = url else { fatalError() }
        // Create URL Request
        var request = URLRequest(url: requestUrl)
        // Specify HTTP Method to use
        request.httpMethod = "POST"
        // Send HTTP Request
        request.timeoutInterval=10.0
        request.setValue(sAppID, forHTTPHeaderField: "ApplicationId")
        request.setValue(sAppKey, forHTTPHeaderField: "ApplicationKey")
        //request.setValue("sqmdndna", forHTTPHeaderField: "CompanyHostName")
        request.setValue(guid, forHTTPHeaderField: "CorrelationId")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        let bodyContent = "{\"Username\":\""+userName+"\",\"SourceApplication\":\"Windows\",\"DeviceInfo\":{\"OS\":\"Windows10\",\"OsVersion\":\"10.0.19044\",\"Certify_App_Version\":\"2.3.367.0\",\"MachineName\":\"testmachine\",\"local_network_name\":\"2.3.367.0\",\"local_network_ip\":\"2.3.367.0\"}}"
        
        body.append(bodyContent.data(using: String.Encoding.utf8)!)
        
        request.httpBody = body
        
        let sem = DispatchSemaphore.init(value: 0)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            //self.lblProcessing.isHidden=true
            // Check if Error took place
            
            if let error = error {
                defer { sem.signal() }
                //print("Error took place \(error)")
                //self.dialogOKCancel(question: "Validate Product Key", text: "Error took place \(error)" )
                return
            }
            
            // Convert HTTP Response Data to a simple String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                var replaced = dataString.replacingOccurrences(of: "\"", with: "")
                replaced = replaced.replacingOccurrences(of: "\\", with: "\"")
                
                let data1 = Data(replaced.utf8)

                do {
                    // make sure this JSON is in the format we expect
                    if let json = try JSONSerialization.jsonObject(with: data1, options:.allowFragments) as? [String: Any] {
                        //let sAccess_token = json["access_token"] as? String
                        sUserID = json["UniqueUserId"] as! String
                        defer { sem.signal() }
                        
                    }
                } catch let error as NSError {
                    defer { sem.signal() }
                    print("Failed to load: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
        sem.wait()
        return sUserID;
    }
    
    func setAuth(userID:String,authMode:String) -> Bool {
        var bReturn:Bool=false
        let APIUrl = sAppURL + "/Authenticate"
        let url = URL(string: APIUrl)
        
        guard let requestUrl = url else { fatalError() }
        // Create URL Request
        var request = URLRequest(url: requestUrl)
        // Specify HTTP Method to use
        request.httpMethod = "POST"
        // Send HTTP Request
        request.timeoutInterval=10.0
        request.setValue(sAppID, forHTTPHeaderField: "ApplicationId")
        request.setValue(sAppKey, forHTTPHeaderField: "ApplicationKey")
        //request.setValue("sqmdndna", forHTTPHeaderField: "CompanyHostName")
        request.setValue(guid, forHTTPHeaderField: "CorrelationId")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        let bodyContent = "{\"user_name\":\""+userID+"\",\"authentication_id\":\""+authMode+"\",\"DeviceInfo\":{\"OS\":\"Windows10\",\"OsVersion\":\"10.0.19044\",\"Certify_App_Version\":\"2.3.367.0\",\"MachineName\":\"testmachine\",\"local_network_name\":\"2.3.367.0\",\"local_network_ip\":\"2.3.367.0\"}}"
        
        body.append(bodyContent.data(using: String.Encoding.utf8)!)
        
        request.httpBody = body
        
        let sem = DispatchSemaphore.init(value: 0)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            //self.lblProcessing.isHidden=true
            // Check if Error took place
            
            if let error = error {
                defer { sem.signal() }
                //print("Error took place \(error)")
                //self.dialogOKCancel(question: "Validate Product Key", text: "Error took place \(error)" )
                return
            }
            
            // Convert HTTP Response Data to a simple String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                //var replaced = dataString.replacingOccurrences(of: "\"", with: "")
                //replaced = replaced.replacingOccurrences(of: "\\", with: "\"")
                bReturn=true;
                let data1 = Data(dataString.utf8)
                //print("Recevied Data: \(dataString)")
                do {
                    // make sure this JSON is in the format we expect
                    if let json = try JSONSerialization.jsonObject(with: data1, options:.allowFragments) as? [String: Any] {
                        //let sAccess_token = json["access_token"] as? String
                        //sUserID = json["UniqueUserId"] as! String
                        bReturn=true;
                        defer { sem.signal() }
                        
                    }
                } catch let error as NSError {
                    defer { sem.signal() }
                    print("Failed to load: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
        sem.wait()
        return bReturn;
    }
    
    func getAuth(userID:String,authID:String) -> Bool {
        var bReturn:Bool=false
        let APIUrl = sAppURL + "/Authenticate"
        let url = URL(string: APIUrl)
        //let guid = NSUUID().uuidString.lowercased()
        guard let requestUrl = url else { fatalError() }
        // Create URL Request
        var request = URLRequest(url: requestUrl)
        // Specify HTTP Method to use
        request.httpMethod = "POST"
        // Send HTTP Request
        request.timeoutInterval=30.0
        request.setValue(sAppID, forHTTPHeaderField: "ApplicationId")
        request.setValue(sAppKey, forHTTPHeaderField: "ApplicationKey")
        //request.setValue("sqmdndna", forHTTPHeaderField: "CompanyHostName")
        request.setValue(guid, forHTTPHeaderField: "CorrelationId")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        let bodyContent = "{\"user_name\":\""+userID+"\",\"authentication_id\":\""+authID+"\",\"DeviceInfo\":{\"OS\":\"Windows10\",\"OsVersion\":\"10.0.19044\",\"Certify_App_Version\":\"2.3.367.0\",\"MachineName\":\"testmachine\",\"local_network_name\":\"2.3.367.0\",\"local_network_ip\":\"2.3.367.0\"}}"
        
        body.append(bodyContent.data(using: String.Encoding.utf8)!)
        
        request.httpBody = body
        
        let sem = DispatchSemaphore.init(value: 0)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            //self.lblProcessing.isHidden=true
            // Check if Error took place
            
            if let error = error {
                defer { sem.signal() }
                print("Error took place \(error)")
                //self.dialogOKCancel(question: "Validate Product Key", text: "Error took place \(error)" )
                bReturn=false
                return
            }
            
            // Convert HTTP Response Data to a simple String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Recevied Data: \(dataString)")
                var replaced = dataString.replacingOccurrences(of: "\\r\\n", with: "")
                                
                let data1 = Data(replaced.utf8)
                print("Recevied Data: \(replaced)")

                do {
                    // make sure this JSON is in the format we expect
                    if let json = try JSONSerialization.jsonObject(with: data1, options:.allowFragments) as? [String: Any] {
                        let response_code = json["response_code"] as! Int
                        //sUserID = json["UniqueUserId"] as! String
                        if(response_code==1){
                            bReturn = true
                        }
                        defer { sem.signal() }
                        
                    }
                } catch let error as NSError {
                    defer { sem.signal() }
                    bReturn=false
                    print("Failed to load: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
        sem.wait()
        return bReturn;
    }
    
    @IBAction func submit_password_click(_ sender: Any) {
        
    }
    
    @IBAction func cancel_password_click(_ sender: Any) {
        
    }
    
    @IBAction func submit_pin_click(_ sender: Any) {
        sMainUserID = getUserID(userName: "Administrator")
        if(setAuth(userID: sMainUserID, authMode: "PIN")) {
            let bReturn = getAuth(userID: sMainUserID, authID: txtPin.stringValue)
            if(!bReturn)
            {
                
            }
        }
    }
    
    @IBAction func cancel_pin_click(_ sender: Any) {
        tabPassword.isHidden=false
       // tabPin.isHidden=true
    }
    
    @IBAction func push_click(_ sender: Any) {
        sMainUserID = getUserID(userName: "Administrator")
        let bReturn = getAuth(userID: sMainUserID, authID: "PUSH")
        if(!bReturn)
        {
            
        }
    }
    
    @IBAction func pin_click(_ sender: Any) {
        tabPassword.isHidden=true
        //tabPin.isHidden=false
    }
    
    @IBAction func rfid_click(_ sender: Any) {
        tabPassword.isHidden=true
        //tabPin.isHidden=true
        tabRFID.isHidden=false
    }
    
}
