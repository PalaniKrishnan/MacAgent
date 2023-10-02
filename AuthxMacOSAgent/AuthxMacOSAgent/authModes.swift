//
//  loginWindow.swift
//  zKeyRegistration
//
//  Created by Shahzad on 10/12/19.
//  Copyright © 2019 Shahzad. All rights reserved.
//

import Cocoa
import Foundation
import OpenDirectory

class authModes: NSWindowController, NSWindowDelegate {
    
    @IBOutlet weak var nsPIN: NSSwitch!
    @IBOutlet weak var nsRFID: NSSwitch!
    @IBOutlet weak var nsPhone: NSSwitch!
    
    @IBOutlet weak var sUIName: NSTextField!
    @IBOutlet weak var sUIPhone: NSTextField!
    @IBOutlet weak var sUIStatus: NSTextField!
    @IBOutlet weak var sUIPhoneType: NSTextField!
    
    @IBOutlet weak var nProgessIndicator: NSProgressIndicator!
    
    var nEnrollRFID:enrollRFID!
    var nEnrollPIN:enrollPIN!
    var nEnrollPhone:enrollPhone!
    
    var sAppID:String!
    var sAppKey:String!
    var sAppURL:String!
    
    var sAppHost:String!
    var sAppAPI:String!
    
    var sUsername:String!
    var sUserUID:String!
    var sUserID:String!
    var sCompanyID:String!
    
    override func windowDidLoad() {
        super.windowDidLoad()
                // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        self.window?.center()
        
        self.window?.titleVisibility = .hidden
        self.window?.titlebarAppearsTransparent = true

        self.window?.styleMask.insert(.fullSizeContentView)

        self.window?.styleMask.remove(.closable)
        self.window?.styleMask.remove(.fullScreen)
        self.window?.styleMask.remove(.miniaturizable)
        self.window?.styleMask.remove(.resizable)
        
        //getPhoneForUser()
      //  GetUserPin()
        //GetRFID()
        LoadAllFactors()
        NotificationCenter.default.addObserver(self, selector: #selector(remoteLoadView(noti:)), name: Notification.Name.Action.CallVC1Method, object: nil)
    }
    
    func LoadAllFactors() {
        nProgessIndicator.isHidden=false
        nProgessIndicator.startAnimation(self)
        getPhoneForUser()
        GetUserPin()
        GetRFID()
        nProgessIndicator.stopAnimation(self)
        nProgessIndicator.isHidden=true
    }
    
    func GetUserPin() -> Void {
        var bReturn:Bool=false
        let APIUrl = self.sAppAPI + "GetUserPin"
        let url = URL(string: APIUrl)
        print(url)
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
        //request.setValue(guid, forHTTPHeaderField: "CorrelationId")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        let bodyContent = "{\"UniqueId\":\""+sUserUID+"\"}"
        
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
                //print("Recevied Data: \(dataString)")
                var replaced = dataString.replacingOccurrences(of: "[", with: "")
                //var replaced = dataString.replacingOccurrences(of: "\"", with: "")
                replaced = replaced.replacingOccurrences(of: "]", with: "")
                
                let data1 = Data(replaced.utf8)
                print("Recevied Data: \(replaced)")

                do {
                    // make sure this JSON is in the format we expect
                    if let json = try JSONSerialization.jsonObject(with: data1, options:.allowFragments) as? [String: Any] {
                        let response_code = json["response_code"] as! Int
                        //sUserID = json["UniqueUserId"] as! String
                        if(response_code==1){
                            let s_response_code = json["response_data"] as! String
                            let json_response_data = try JSONSerialization.jsonObject(with:Data(s_response_code.utf8), options:.allowFragments) as? [String: Any]
                            let bStatus = json_response_data?["PinStatus"] as! Bool
                            if(bStatus==true) {
                                self.nsPIN.state = NSControl.StateValue.on
                            }
                            else{
                                self.nsPIN.state = NSControl.StateValue.off
                            }
                        }
                        else
                        {
                            self.nsPIN.state = NSControl.StateValue.off
                        }
                        
                        defer { sem.signal() }
                        
                    }
                } catch let error as NSError {
                    defer { sem.signal() }
                    bReturn=false
                    //print("Failed to load: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
        sem.wait()
        return;
    }
    
    func GetRFID() -> Void {
        var bReturn:Bool=false
        let APIUrl = self.sAppAPI + "GetAuthenticateRFID"
        let url = URL(string: APIUrl)
        print(url)
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
        //request.setValue(guid, forHTTPHeaderField: "CorrelationId")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        let bodyContent = "{\"user_name\":\""+sUserUID+"\"}"
        
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
                //print("Recevied Data: \(dataString)")
                var replaced = dataString.replacingOccurrences(of: "[", with: "")
                //var replaced = dataString.replacingOccurrences(of: "\"", with: "")
                replaced = replaced.replacingOccurrences(of: "]", with: "")
                
                let data1 = Data(replaced.utf8)
                print("Recevied Data: \(replaced)")

                do {
                    // make sure this JSON is in the format we expect
                    if let json = try JSONSerialization.jsonObject(with: data1, options:.allowFragments) as? [String: Any] {
                        let response_code = json["response_code"] as! Int
                        //sUserID = json["UniqueUserId"] as! String
                        if(response_code==1){
                            self.nsRFID.state = NSControl.StateValue.on
                        }
                        else
                        {
                            self.nsRFID.state = NSControl.StateValue.off
                        }
                        
                        defer { sem.signal() }
                        
                    }
                } catch let error as NSError {
                    defer { sem.signal() }
                    bReturn=false
                    //print("Failed to load: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
        sem.wait()
        return;
    }
    
    func getPhoneForUser() -> Void {
        var bReturn:Bool=false
        let APIUrl = self.sAppAPI + "GetPhonesForUser"
        let url = URL(string: APIUrl)
        print(url)
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
        //request.setValue(guid, forHTTPHeaderField: "CorrelationId")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        let bodyContent = "{\"user_name\":\""+sUserUID+"\",\"UserId\":\""+sUserID+"\",\"CompanyId\":\""+sCompanyID+"\",\"DeviceInfo\":{\"OS\":\"Windows10\",\"OsVersion\":\"10.0.19044\",\"Certify_App_Version\":\"2.3.367.0\",\"MachineName\":\"testmachine\",\"local_network_name\":\"2.3.367.0\",\"local_network_ip\":\"2.3.367.0\"}}"
        
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
                //print("Recevied Data: \(dataString)")
                var replaced = dataString.replacingOccurrences(of: "[", with: "")
                //var replaced = dataString.replacingOccurrences(of: "\"", with: "")
                replaced = replaced.replacingOccurrences(of: "]", with: "")
                
                let data1 = Data(replaced.utf8)
                print("Recevied Data: \(replaced)")

                do {
                    // make sure this JSON is in the format we expect
                    if let json = try JSONSerialization.jsonObject(with: data1, options:.allowFragments) as? [String: Any] {
                        let UserStatus = json["MobileAppActivationStatus"] as! Int
                        //sUserID = json["UniqueUserId"] as! String
                        DispatchQueue.main.async {
                            if(UserStatus==1){
                                self.sUIName.stringValue=self.sUsername
                                self.sUIPhone.stringValue=json["MobileNumber"] as! String
                                self.sUIStatus.textColor = NSColor.green
                                self.sUIStatus.stringValue="Active"
                                self.sUIPhoneType.stringValue = json["MobilePlatform"] as! String
                                self.nsPhone.state = NSControl.StateValue.on
                            }
                            else
                            {
                                self.sUIName.stringValue=self.sUsername
                                self.sUIPhone.stringValue=json["MobileNumber"] as! String
                                self.sUIPhoneType.stringValue=""
                                self.sUIStatus.textColor = NSColor.red
                                self.sUIStatus.stringValue="Inactive"
                                self.nsPhone.state = NSControl.StateValue.off
                            }
                        }
                        
                        defer { sem.signal() }
                        
                    }
                } catch let error as NSError {
                    defer { sem.signal() }
                    bReturn=false
                    //print("Failed to load: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
        sem.wait()
        return;
    }
        
    func load_app_setting() -> Bool{
        
        let bReturn:Bool = false
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
            }
        }
        catch {/* error handling here */}
        
        return bReturn
    }
    
    @IBAction func top_bar_close_btn(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    func deactivateRFID() -> Bool {
        var bReturn:Bool=false
        let APIUrl = self.sAppAPI + "DeactivateRFID"
        let url = URL(string: APIUrl)
        print(url)
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
        //request.setValue(guid, forHTTPHeaderField: "CorrelationId")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let guid = NSUUID().uuidString.lowercased()
        var body = Data()
       
        let bodyContent = "{\"user_name\":\""+sUserUID+"\",\"device_data\":{\"OS\":\"Windows10\",\"OsVersion\":\"10.0.19044\",\"Certify_App_Version\":\"2.3.367.0\",\"MachineName\":\"testmachine\",\"local_network_name\":\"2.3.367.0\",\"local_network_ip\":\"2.3.367.0\"}}"
        
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
                //print("Recevied Data: \(dataString)")
                var replaced = dataString.replacingOccurrences(of: "[", with: "")
                //var replaced = dataString.replacingOccurrences(of: "\"", with: "")
                replaced = replaced.replacingOccurrences(of: "]", with: "")
                
                let data1 = Data(replaced.utf8)
                print("Recevied Data: \(replaced)")

                do {
                    // make sure this JSON is in the format we expect
                    if let json = try JSONSerialization.jsonObject(with: data1, options:.allowFragments) as? [String: Any] {
                        let UserStatus = json["response_code"] as! Int
                        //sUserID = json["UniqueUserId"] as! String
                        if(UserStatus==1){
                            bReturn=true
                        }
                        else
                        {
                            let response_text = json["response_text"] as! String
                            self.dialogOK(question: "Warning", text: response_text, alterStyle: "warn")
                            bReturn=false
                        }
                        
                        defer { sem.signal() }
                        
                    }
                } catch let error as NSError {
                    defer { sem.signal() }
                    bReturn=false
                    //print("Failed to load: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
        sem.wait()
        return bReturn;
    }
    @IBAction func nsRFID_action(_ sender: Any) {
        if(nsRFID.state == NSControl.StateValue.on)
        {
           // NSApp.activate(ignoringOtherApps: true)
            nEnrollRFID = enrollRFID(windowNibName: NSNib.Name("enrollRFID"))
            
            nEnrollRFID.sAppID = self.sAppID
            nEnrollRFID.sAppKey = self.sAppKey
            nEnrollRFID.sAppURL = self.sAppURL
            nEnrollRFID.sAppAPI = self.sAppAPI
            nEnrollRFID.sAppHost = self.sAppHost
            nEnrollRFID.sUserUID = self.sUserUID
            nEnrollRFID.sUserID = self.sUserID
            nEnrollRFID.sCompanyID = self.sCompanyID
            
            nEnrollRFID.showWindow(self)
            
        }
        else
        {
            let bReturn:Bool = dialogQuestion(question: "Warning", text: "This will deactive card, are you sure ?", alterStyle: "warn")
            if(bReturn)
            {
                if(deactivateRFID()){
                    dialogOK(question: "Information", text: "Card Removed", alterStyle: "info")
                }
            }
            else
            {
                nsRFID.state = NSControl.StateValue.on
            }
        }
    }
    
    @IBAction func refresh_action(_ sender: Any) {
        LoadAllFactors()
    }
    
    func dialogQuestion(question: String, text: String, alterStyle:String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        
        if(alterStyle=="error"){
            alert.alertStyle = NSAlert.Style.critical
        }
        else if(alterStyle=="info"){
            alert.alertStyle = NSAlert.Style.informational
        }
        else if(alterStyle=="warn"){
                alert.alertStyle = NSAlert.Style.warning
        }
        
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Yes")
        
        
        return alert.runModal() == NSApplication.ModalResponse.alertSecondButtonReturn
    }
    
    func dialogOK(question: String, text: String, alterStyle:String) -> Void {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        
        if(alterStyle=="error"){
            alert.alertStyle = NSAlert.Style.critical
        }
        else if(alterStyle=="info"){
            alert.alertStyle = NSAlert.Style.informational
        }
        else if(alterStyle=="warn"){
                alert.alertStyle = NSAlert.Style.warning
        }
                
        alert.addButton(withTitle: "OK")
               
        alert.runModal()
    }
    
    func deactivatePIN() -> Bool {
        var bReturn:Bool=false
        let APIUrl = self.sAppAPI + "ManageUserPin"
        let url = URL(string: APIUrl)
        print(url)
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
        //request.setValue(guid, forHTTPHeaderField: "CorrelationId")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        let bodyContent = "{\"unique_id\":\""+sUserUID+"\",\"Pin\":\"\",\"PinStatus\":false}"
        
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
                //print("Recevied Data: \(dataString)")
                var replaced = dataString.replacingOccurrences(of: "[", with: "")
                //var replaced = dataString.replacingOccurrences(of: "\"", with: "")
                replaced = replaced.replacingOccurrences(of: "]", with: "")
                
                let data1 = Data(replaced.utf8)
                print("Recevied Data: \(replaced)")

                do {
                    // make sure this JSON is in the format we expect
                    if let json = try JSONSerialization.jsonObject(with: data1, options:.allowFragments) as? [String: Any] {
                        let UserStatus = json["response_code"] as! Int
                        //sUserID = json["UniqueUserId"] as! String
                        if(UserStatus==1){
                            bReturn=true
                        }
                        else
                        {
                            bReturn=false
                        }
                        
                        defer { sem.signal() }
                        
                    }
                } catch let error as NSError {
                    defer { sem.signal() }
                    bReturn=false
                    //print("Failed to load: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
        sem.wait()
        return bReturn;
    }
    
    @IBAction func nsPIN_action(_ sender: Any) {
        if(nsPIN.state == NSControl.StateValue.on)
        {
           // NSApp.activate(ignoringOtherApps: true)
            nEnrollPIN = enrollPIN(windowNibName: NSNib.Name("enrollPIN"))
            
            nEnrollPIN.sAppID = self.sAppID
            nEnrollPIN.sAppKey = self.sAppKey
            nEnrollPIN.sAppURL = self.sAppURL
            nEnrollPIN.sAppAPI = self.sAppAPI
            nEnrollPIN.sAppHost = self.sAppHost
            nEnrollPIN.sUserUID = self.sUserUID
            
            nEnrollPIN.showWindow(self)
            
            //self.nEnrollPIN?.window?.orderFront(self)
            
            
            //NSApp.runModal(for: nEnrollPIN.window)
        }
        else
        {
            let bReturn:Bool = dialogQuestion(question: "Warning", text: "This will deactive pin, are you sure ?", alterStyle: "warn")
            if(bReturn)
            {
                if(deactivatePIN()){
                    dialogOK(question: "Information", text: "PIN Deactivated", alterStyle: "info")
                }
            }
            else
            {
                nsPIN.state = NSControl.StateValue.on
            }
        }
    }
    
    @IBAction func nsPhone_click(_ sender: Any) {
        if(nsPhone.state == NSControl.StateValue.on)
        {
           // NSApp.activate(ignoringOtherApps: true)
            nEnrollPhone = enrollPhone(windowNibName: NSNib.Name("enrollPhone"))
            
            nEnrollPhone.sAppID = self.sAppID
            nEnrollPhone.sAppKey = self.sAppKey
            nEnrollPhone.sAppURL = self.sAppURL
            nEnrollPhone.sUserUID = self.sUserUID
            nEnrollPhone.sUserID = self.sUserID
            nEnrollPhone.sCompanyID = self.sCompanyID
            nEnrollPhone.showWindow(self)
            
        }
        else
        {
            nsPhone.state = NSControl.StateValue.on        }
    }
    
    @objc func remoteLoadView(noti: Notification){
        guard let dic = noti.object as? Dictionary<String, String>, let remote_command = dic["command"]  else {
            return
        }
        
        if remote_command == "load_factors"{
            LoadAllFactors()
        }
        
        if remote_command == "load_phone_factors"{
            getPhoneForUser()
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension Notification.Name {
    struct Action {
        //notification name
        static let CallVC1Method = Notification.Name("CallVC1Method")
    }
}
// --------------------------------------------------------------------------------
