//
//  AuthxSignIn.swift
//  AuthxConfiguration
//
//  Created by Admin on 19.11.2022.
//

import Cocoa
import Security.AuthorizationPlugin
import OpenDirectory
import Foundation
import SwiftUI
import os
import SecurityInterface

class AuthxLogIn: NSWindowController {
    
    @IBOutlet weak var txtUsername: NSTextField!
    @IBOutlet weak var txtPassword: NSSecureTextField!
    @IBOutlet weak var infoMsg: NSTextField!
    @IBOutlet weak var txtPin: NSTextField!
    
    var mechCallbacks: AuthorizationCallbacks?
    var mechEngine: AuthorizationEngineRef?
    var mechView: SFAuthorizationPluginView?
    
    var sAppID:String = ""
    var sAppKey:String = ""
    var sAppURL:String=""
    var sMainUserID:String=""
    var sUsername:String=""
    var sPassword:String=""
    
    var sAppHost:String!
    var sAppAPI:String!
    
    var sUserUID:String!
    var sUserID:String!
    var sCompanyID:String!
    
    var usertype:String="local"
    var domain:String=""
    
    var nRFID:Int32!
    var timer: Timer?
    var bTResult=false
    var sRFID:String!="0"
    
    @IBOutlet weak var sRFIDStatus: NSTextField!
    
    @IBOutlet weak var tabPassword: NSTabView!
    @IBOutlet weak var tabPin: NSTabView!
    @IBOutlet weak var tabRFID: NSTabView!
    
    var guid = NSUUID().uuidString.lowercased()
    
    override func windowDidLoad() {
        super.windowDidLoad()
                
        self.window?.level = .screenSaver
        self.window?.orderFrontRegardless()
        self.window?.canBecomeVisibleWithoutLogin=true
        
        self.window?.titlebarAppearsTransparent = true
        self.window?.isMovable = false
        
        self.window?.makeKeyAndOrderFront(self)
        
        load_app_setting()
        
        tabPin.isHidden=true
        tabRFID.isHidden=true
        txtUsername.becomeFirstResponder()
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
                    self.sAppURL = cols[2]
                    let splitedArr = cols[2].components(separatedBy: "-")
                    if splitedArr.count > 1 {
                        let arrayWithHost = splitedArr[1].components(separatedBy: ".")
                        if arrayWithHost.count > 2 {
                            self.sAppHost = arrayWithHost[0]
                            self.sAppAPI = splitedArr[0]+"."+arrayWithHost[1]+"."+arrayWithHost[2]
                        }
                    }
                }
            }
        }
        catch {/* error handling here */}
        
    }
    
    func getUserID(userName:String) -> String {
         // var sUserID:String=""
          let APIUrl = sAppAPI + "Login/LoginAsync"
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
          request.setValue(sAppHost, forHTTPHeaderField: "CompanyHostName")
          request.setValue(guid, forHTTPHeaderField: "PcIdentifier")
          request.setValue("application/json", forHTTPHeaderField: "Content-Type")
          
          var body = Data()
          let bodyContent = "{\"Username\":\""+userName+"\",\"ApplicationKey\":\""+sAppID+"\",\"SecretKey\":\""+sAppKey+"\",\"HostName\":\""+sAppHost+"\",\"SourceApplication\":\"Windows\",\"DeviceInfo\":{\"OS\":\"Windows10\",\"OsVersion\":\"10.0.19044\",\"Certify_App_Version\":\"2.3.367.0\",\"MachineName\":\"testmachine\",\"local_network_name\":\"2.3.367.0\",\"local_network_ip\":\"2.3.367.0\"}}"
          
          body.append(bodyContent.data(using: String.Encoding.utf8)!)
          
          request.httpBody = body
          print(request.allHTTPHeaderFields)
          let str = String(decoding: request.httpBody!, as: UTF8.self)
          print(str)
          let sem = DispatchSemaphore.init(value: 0)
          
          let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
              //self.lblProcessing.isHidden=true
              // Check if Error took place
              print(response.debugDescription)
              if let error = error {
                  defer { sem.signal() }
                  //print("Error took place \(error)")
                  //self.dialogOKCancel(question: "Validate Product Key", text: "Error took place \(error)" )
                  return
              }
              
              // Convert HTTP Response Data to a simple String
              if let data = data, let dataString = String(data: data, encoding: .utf8) {
                  print(dataString)
                  var replaced = dataString.replacingOccurrences(of: "\"", with: "")
                  replaced = replaced.replacingOccurrences(of: "\\", with: "\"")
                  
                  let data1 = Data(replaced.utf8)

                  do {
                      // make sure this JSON is in the format we expect
                      if let json = try JSONSerialization.jsonObject(with: data, options:.allowFragments) as? [String: Any] {
                          //let sAccess_token = json["access_token"] as? String
                          if let uniqueID = json["UniqueUserId"] as? String, let userId = json["UserId"] as? String, let companyId = json["CompanyId"] as? String {
                              self.sUserUID = uniqueID
                              self.sUserID = userId
                              self.sCompanyID = companyId
                          }
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
        let APIUrl = sAppAPI + "/Authenticate"
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
        request.setValue(sAppHost, forHTTPHeaderField: "CompanyHostName")
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
        let APIUrl = sAppAPI + "/Authenticate"
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
        request.setValue(sAppHost, forHTTPHeaderField: "CompanyHostName")
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
                //print("Error took place \(error)")
                //self.dialogOKCancel(question: "Validate Product Key", text: "Error took place \(error)" )
                bReturn=false
                return
            }
            
            // Convert HTTP Response Data to a simple String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                //print("Recevied Data: \(dataString)")
                var replaced = dataString.replacingOccurrences(of: "\\r\\n", with: "")
                                
                let data1 = Data(replaced.utf8)
                //print("Recevied Data: \(replaced)")

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
    
    func authenticateLocalUser(username: String, password: String) -> Bool {
        do {
            let session = ODSession()
            var node : ODNode?=nil
            
            if usertype=="local"
            {
                node = try ODNode(session: session, type: ODNodeType(kODNodeTypeLocalNodes))
            }
            else
            {
                let serverName : String = "/Active Directory/" + domain + "/All Domains"
                node = try ODNode(session: session, name: serverName)
            }
            
            let record = try node?.record(withRecordType: kODRecordTypeUsers, name: username, attributes: nil)
            try record?.verifyPassword(password)
            return true
        } catch {
            return false
        }
    }
    
    func process_login(userName:String,passWord:String ) {
        
        //self.infoMsg.isHidden=false
        self.infoMsg.stringValue = ""
        let success = authenticateLocalUser(username: userName, password: passWord)
        if(!success)
        {
            self.infoMsg.isHidden=false
            self.infoMsg.textColor = NSColor.red
            self.infoMsg.stringValue = "The username/password you entered is invalid."
            //self.showNSAlert(message: "The password you entered is invalid. Please check password and try again.")
        }
        else
        {
            //self.infoMsg.isHidden=false
            //self.infoMsg.textColor = NSColor.black
            //self.infoMsg.stringValue = "Logging you in please wait."
            //self.passwordlessUserLabel.stringValue="Logging in, please wait..."
            //progressIndicator.isHidden=false
            let userNametempdata = userName
            let userNamedata = userNametempdata.data(using: .utf8)
            var userNamevalue = AuthorizationValue(length: (userNamedata?.count)!, data: UnsafeMutableRawPointer(mutating: (userNamedata! as NSData).bytes.bindMemory(to: Void.self, capacity: (userNamedata?.count)!)))
            
            let passwordTempdata = passWord
            let passwordData = passwordTempdata.data(using: .utf8)
            var passwordValue = AuthorizationValue(length: (passwordData?.count)!, data: UnsafeMutableRawPointer(mutating: (passwordData! as NSData).bytes.bindMemory(to: Void.self, capacity: (passwordData?.count)!)))
                        
            var error = mechCallbacks?.SetContextValue(mechEngine!,kAuthorizationEnvironmentUsername,.extractable, &userNamevalue)
            error = mechCallbacks?.SetContextValue(mechEngine!,kAuthorizationEnvironmentPassword,.extractable, &passwordValue)
            error = mechCallbacks?.SetResult(mechEngine!,.allow)
            
            if(error==noErr)
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.mechView?.callbacks().deallocate()
                }
                //self.window?.close()
                //self.backgroundWindow.close()
                //NSApp.stopModal()
            }
        }
    }
    
    @IBAction func rbtnSubmit_click(_ sender: Any) {
        self.infoMsg.isHidden=true
        let userNametempdata = txtUsername.stringValue + "\0"
        let passwordTempdata = txtPassword.stringValue + "\0"
        process_login(userName:userNametempdata,passWord:passwordTempdata)
    }
    
    @IBAction func rbtnCancel_click(_ sender: Any) {
    }
    
    
    @IBAction func submit_password_click(_ sender: Any) {
        
    }
    
    @IBAction func cancel_password_click(_ sender: Any) {
        
    }
    
    @IBAction func submit_pin_click(_ sender: Any) {
        self.infoMsg.isHidden=true
        sMainUserID = getUserID(userName: self.sUsername)
        self.infoMsg.stringValue = sMainUserID
        if(setAuth(userID: sMainUserID, authMode: "PIN")) {
            let bReturn = getAuth(userID: sMainUserID, authID: txtPin.stringValue)
            if(bReturn)
            {
                self.infoMsg.isHidden=false
                self.infoMsg.textColor = NSColor.black
                self.infoMsg.stringValue = "PIN authentication done.Logging you in please wait."
                let userNametempdata = self.sUsername + "\0"
                let passwordTempdata = self.sPassword + "\0"
                process_login(userName:userNametempdata,passWord:passwordTempdata)
                //self.window?.close();
            }
            else {
                self.infoMsg.isHidden=false
                self.infoMsg.textColor = NSColor.red
                self.infoMsg.stringValue = "PIN authentication failed."
            }
        }
        else{
            self.infoMsg.isHidden=false
            self.infoMsg.textColor = NSColor.red
            self.infoMsg.stringValue = "PIN authentication failed."
        }
    }
    
    @IBAction func cancel_pin_click(_ sender: Any) {
        //self.infoMsg.isHidden=false
        //self.infoMsg.stringValue = "cancel_pin_click."
        
        tabPassword.isHidden=false
        tabPin.isHidden=true
        tabRFID.isHidden=true
    }
    
    @IBAction func push_click(_ sender: Any) {
        self.infoMsg.isHidden=true
        sMainUserID = getUserID(userName: self.sUsername)
        let bReturn = getAuth(userID: sMainUserID, authID: "PUSH")
        if(bReturn)
        {
            self.infoMsg.isHidden=false
            self.infoMsg.textColor = NSColor.black
            self.infoMsg.stringValue = "PUSH authentication done.Logging you in please wait."
            let userNametempdata = self.sUsername + "\0"
            let passwordTempdata = self.sPassword + "\0"
            process_login(userName:userNametempdata,passWord:passwordTempdata)
            //self.window?.close();
        }
        else {
            self.infoMsg.isHidden=false
            self.infoMsg.textColor = NSColor.red
            self.infoMsg.stringValue = "PUSH authentication failed."
        }
    }
    
    @IBAction func pin_click(_ sender: Any) {
        
        tabPassword.isHidden=true
        tabPin.isHidden=false
        tabRFID.isHidden=true
    }
    
    func grantPermissions() {
        if !IOHIDRequestAccess(kIOHIDRequestTypeListenEvent) {
            //print("Not granted input monitoring")
            sRFIDStatus.stringValue = "Not granted input monitoring"
        } else {
            //print("Granted input monitoring")
            sRFIDStatus.stringValue = "Granted input monitoring"
        }
    }
    
    @IBAction func rfid_click(_ sender: Any) {
        
        tabPassword.isHidden=true
        tabPin.isHidden=true
        tabRFID.isHidden=false
        grantPermissions()
        //self.startTimer()
        
    
    }
    
    @IBAction func rfid_cancel_click(_ sender: Any) {
        
        tabPassword.isHidden=false
        tabPin.isHidden=true
        tabRFID.isHidden=true
        self.stopTimer()
    }
    
    func dialogOKCancel(question: String, text: String) -> Void {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = NSAlert.Style.critical
        alert.addButton(withTitle: "ok")
        alert.runModal()
    }
    
    func shell(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/sh"
        task.standardInput = nil
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        return output
    }
    
    @objc func loop() {

        if(self.bTResult==false)
        {
            
            //nRFID = GetActiveRFID()
            var sOutFound:String = shell("/Users/Shared/getrfid --getid")
            
            if sOutFound.contains("-")
            {
                sRFIDStatus.textColor = NSColor.red
                sRFIDStatus.stringValue = sOutFound
                
                sOutFound="1001"
            }
            else {
            
            nRFID = Int32(sOutFound);//shell("/User/Shared/getrfid --getid")
            
            
            if(nRFID==1001)
            {
                sRFIDStatus.textColor = NSColor.red
                sRFIDStatus.stringValue = "Reader not connected"
            }
            else if(nRFID==0)
            {
                sRFIDStatus.textColor = NSColor.blue
                sRFIDStatus.stringValue = "No id found, Please put card on the reader."
            }
            else
            {
                self.stopTimer()
                sRFIDStatus.textColor = NSColor.green
                sRFIDStatus.stringValue = "ID found start authentication please wait."
                                
            }
            }
        }
        else
        {
            self.bTResult=false;
            self.stopTimer()
            //dialogOK(question: "Information", text: "Mobile successfully added", alterStyle: "info")
            //NotificationCenter.default.post(name: Notification.Name.Action.CallVC1Method, object: ["command": "load_phone_factors"])
            super.close()
        }
    }
    func startTimer() {
        
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.loop), userInfo: nil, repeats: true)
        }
    }
    func stopTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
}
