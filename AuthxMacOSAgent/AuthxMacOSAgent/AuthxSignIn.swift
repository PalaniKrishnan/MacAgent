//
//  AuthxSignIn.swift
//  AuthxConfiguration
//
//  Created by Admin on 19.11.2022.
//

import Foundation
import AppKit
import SwiftUI
import OpenDirectory

class AuthxSignIn: NSWindowController {
    
    var sAppID:String = ""
    var sAppKey:String = ""
    var sAppURL:String=""
    
    var sAppHost:String = ""
    var sAppAPI:String = ""
    
    var sMainUserID:String!
    var sUsername:String!
    var sPassword:String!
    var sUserID:String!
    var sCompanyID:String!
    
    public var usertype : String = "local"
    public var domain : String = ""
    
    @IBOutlet weak var txtUsername: NSTextField!
    @IBOutlet weak var txtPassword: NSTextField!
    @IBOutlet weak var txtPin: NSTextField!
    @IBOutlet weak var infoMsg: NSTextField!
    @IBOutlet weak var instructionMsg: NSTextField!
    @IBOutlet weak var UserName: NSTextField!
    @IBOutlet weak var CompanyName: NSTextField!

    @IBOutlet weak var tabPassword: NSTabView!
    @IBOutlet weak var tabPin: NSTabView!
    @IBOutlet weak var tabRFID: NSTabView!
    
    @IBOutlet weak var splitView: NSSplitView!
    @IBOutlet weak var leftView: NSView!
    @IBOutlet weak var middleView: NSView!
    @IBOutlet weak var rightView: NSView!

    @IBOutlet weak var authModeImageView: NSImageView!

    var nRFID:Int32!
    var timer: Timer?
    var bTResult=false
    var sRFID:String!="0"
    var isRFIDenrolled = false
    var isRFIDauthenticated = false

    @IBOutlet weak var sRFIDStatus: NSTextField!

    var guid = NSUUID().uuidString.lowercased()
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.leftView.wantsLayer = true
        self.leftView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.6).cgColor
        self.rightView.wantsLayer = true
        self.rightView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.6).cgColor
        
        load_app_setting()

        tabPin.isHidden=true
        tabRFID.isHidden=true
        txtUsername.becomeFirstResponder()
        
        getAuthXSettings()
        getAuthXFactorsList()
        closeLeftSidebar()
        closeRightSideBar()
//        NSEvent.addGlobalMonitorForEvents(matching: NSEvent.EventTypeMask.mouseMoved, handler: {(mouseEvent:NSEvent) in
//                let position = mouseEvent.locationInWindow
//            print(position)
//                if position.x < 100 {
//                    self.openSidebar()
//                } else {
//                    self.closeSidebar()
//                }
//        })
        
        //sMainUserID = getUserID(userName: "Administrator")
    }
    
    @IBAction func leftSideBarBtnClicked (_ sender: Any) {
        
        guard let btn = sender as? NSButton else {
            return
        }

        if self.leftView.isHidden == true {
            self.openLeftSidebar()
            btn.image = NSImage(named: "hide_sidebar")
        } else {
            self.closeLeftSidebar()
            btn.image = NSImage(named: "show_sidebar")
        }
        btn.bezelColor = .white

    }
    
    @IBAction func rightSideBarBtnClicked (_ sender: Any) {
        
        guard let btn = sender as? NSButton else {
            return
        }

        if self.rightView.isHidden == true {
            self.openRightSideBar()
            btn.image = NSImage(named: "show_sidebar")
        } else {
            self.closeRightSideBar()
            btn.image = NSImage(named: "hide_sidebar")
        }
        btn.bezelColor = .white

    }
    
    func closeLeftSidebar () {
        let leftSideView = splitView.subviews[0] as NSView
        let centerView = splitView.subviews[1] as NSView
        leftSideView.isHidden = true
        let containerFrame = splitView.frame
        centerView.frame.size = NSMakeSize(containerFrame.size.width, containerFrame.size.height)
        splitView.display()
    }

    func openLeftSidebar () {
        self.closeRightSideBar()
        let leftSideView = splitView.subviews[0] as NSView
        leftSideView.isHidden = false
        let containerFrame = splitView.frame
        leftSideView.frame.size = NSMakeSize(140, containerFrame.size.height)
        splitView.display()
    }
    
    func closeRightSideBar() {
        let rightSideView = splitView.subviews[2] as NSView
        let centerView = splitView.subviews[1] as NSView
        rightSideView.isHidden = true
        let containerFrame = splitView.frame
        centerView.frame.size = NSMakeSize(containerFrame.size.width, containerFrame.size.height)
        splitView.display()
    }
   
    func openRightSideBar() {
        self.closeLeftSidebar()
        let rightSideView = splitView.subviews[2] as NSView
        rightSideView.isHidden = false
        let containerFrame = splitView.frame
        rightSideView.frame.size = NSMakeSize(200, containerFrame.size.height)
        splitView.display()
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
                if (!cols[3].isEmpty)
                {
                    self.sUsername=cols[3]
                    DispatchQueue.main.async {
                        self.UserName.stringValue = self.sUsername
                    }
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
    
    func getUserID(userName:String) {
        //  var sUserID:String=""
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
                          
                          self.sMainUserID = json["UniqueUserId"] as! String
                                                  
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
          //return sUserID;
      }
    
    func getAuthXSettings() {
        let APIUrl = sAppAPI + "GetAppAuthSettings"
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
        request.setValue(guid, forHTTPHeaderField: "PcIdentifier")
        request.setValue(guid, forHTTPHeaderField: "TraceId")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
        let deviceData = ["BrowserName":nil,
                          "BrowserVersion":nil,
                          "OS":"Microsoft Windows 10 Pro",
                          "OsVersion":"10.0.19045",
                          "DeviceId":"CERTIFYLT-332",
                          "Certify_App_Version":"2.4.23.1",
                          "MachineName":"CERTIFYLT-332",
                          "AD_Domain":"CERTIFY",
                          "HostName":sAppHost,
                          "Local_IP":nil,
                          "IsDelegatedAccess":false] as [String : AnyObject]
        
        
        let userGeo = ["Ip":nil,"Country":nil,"City":nil,"State":nil] as [String : AnyObject]
        let bioRequest = ["bioIndex":nil] as [String : AnyObject]

        
        let parameters =  ["Username":"",
                           "UserId":nil,
                           "CompanyName":nil,
                           "CompanyId":nil,
                           "UserType":"Admin",
                           "ApplicationKey":sAppID,
                           "SecretKey":sAppKey,
                           "Password":nil,
                           "grant_type":nil,
                           "ClientKey":nil,
                           "SessionId":nil,
                           "Totp":nil,
                           "FacilityAccessCode":nil,
                           "CardId":nil,
                           "AuthFactor":nil,
                           "SourceApplication":"Windows",
                           "EventType":21,
                           "BioRequest":bioRequest,
                           "UserGeographics":userGeo,
                           "DeviceInfo": deviceData] as [String : AnyObject]
        
        print(parameters)
            
        guard let postData = (try? JSONSerialization.data(withJSONObject: parameters, options: [])) else  {
            return
        }
            
        request.httpBody = postData
        
        let sem = DispatchSemaphore.init(value: 0)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            //self.lblProcessing.isHidden=true
            // Check if Error took place
            
            if let error = error {
                defer { sem.signal() }
                print("Error took place \(error)")
                //self.dialogOKCancel(question: "Validate Product Key", text: "Error took place \(error)" )
                return
            }
            
            // Convert HTTP Response Data to a simple String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Recevied Data: \(dataString)")
               // var replaced = dataString.replacingOccurrences(of: "\\r\\n", with: "")
                                
//                let data1 = Data(replaced.utf8)
//                print("Recevied Data: \(replaced)")

                do {
                    // make sure this JSON is in the format we expect
                    if let json = try JSONSerialization.jsonObject(with: data, options:.allowFragments) as? [String: Any] {
                        //let response_code = json["response_code"] as! Int
                        //sUserID = json["UniqueUserId"] as! String
//                        if(response_code==1){
//                            
//                        }
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
    }
    
    
    func getAuthXFactorsList() {
        let APIUrl = sAppAPI + "GetUserAuthFactorsList"
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
        request.setValue(guid, forHTTPHeaderField: "PcIdentifier")
        request.setValue(guid, forHTTPHeaderField: "TraceId")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
        let deviceData = ["BrowserName":nil,
                          "BrowserVersion":nil,
                          "OS":"Microsoft Windows 10 Pro",
                          "OsVersion":"10.0.19045",
                          "DeviceId":"CERTIFYLT-332",
                          "Certify_App_Version":"2.4.23.1",
                          "MachineName":"CERTIFYLT-332",
                          "AD_Domain":"CERTIFY",
                          "HostName":sAppHost,
                          "Local_IP":nil,
                          "IsDelegatedAccess":false] as [String : AnyObject]
        
        
        let userGeo = ["Ip":nil,"Country":nil,"City":nil,"State":nil] as [String : AnyObject]
        let bioRequest = ["bioIndex":nil] as [String : AnyObject]

        
        let parameters =  ["Username":self.sMainUserID,
                           "UserId":self.sUserID,
                           "CompanyName":nil,
                           "CompanyId":self.sCompanyID,
                           "UserType":nil,
                           "ApplicationKey":sAppID,
                           "SecretKey":sAppKey,
                           "Password":nil,
                           "grant_type":nil,
                           "ClientKey":nil,
                           "SessionId":nil,
                           "Totp":nil,
                           "FacilityAccessCode":nil,
                           "CardId":nil,
                           "AuthFactor":nil,
                           "SourceApplication":"Windows",
                           "EventType":21,
                           "BioRequest":bioRequest,
                           "UserGeographics":userGeo,
                           "DeviceInfo": deviceData] as [String : AnyObject]
        
        print(parameters)
            
        guard let postData = (try? JSONSerialization.data(withJSONObject: parameters, options: [])) else  {
            return
        }
            
        request.httpBody = postData
        
        let sem = DispatchSemaphore.init(value: 0)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            //self.lblProcessing.isHidden=true
            // Check if Error took place
            
            if let error = error {
                defer { sem.signal() }
                print("Error took place \(error)")
                //self.dialogOKCancel(question: "Validate Product Key", text: "Error took place \(error)" )
                return
            }
            
            // Convert HTTP Response Data to a simple String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Recevied Data: \(dataString)")
               // var replaced = dataString.replacingOccurrences(of: "\\r\\n", with: "")
                                
//                let data1 = Data(replaced.utf8)
//                print("Recevied Data: \(replaced)")

                do {
                    // make sure this JSON is in the format we expect
                    if let json = try JSONSerialization.jsonObject(with: data, options:.allowFragments) as? [String: Any] {
                        //let response_code = json["response_code"] as! Int
                        //sUserID = json["UniqueUserId"] as! String
//                        if(response_code==1){
//
//                        }
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
    }
    
    
    /*
    func setAuth(userID:String,authMode:String) -> Bool {
        var bReturn:Bool=false
        let APIUrl = sAppAPI + "Authenticate"
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
    */
     
    func getAuth(endUrl:String, userID:String, authID:String) -> Bool {
        var bReturn:Bool=false
        let APIUrl = sAppAPI + endUrl
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
                
        let deviceData = ["os":"Microsoft Windows 10 Pro",
                          "os_version":"10.0.19044",
                          "app_version":"2.4.15.1.0",
                          "device_name":"CERTIFYLT-332",
                          "local_network_name":nil,
                          "local_network_ip":nil,
                          "local_domain":"CERTIFY",
                          "pushTypeSCE":0,
                          "oftr":false,
                          "signon_application":"WinLoginProcess"] as [String : AnyObject]
        
        let parameters =  ["user_name": userID,
                           "authentication_id": authID,
                           "device_data": deviceData] as [String : AnyObject]
        
        print(parameters)
            
        guard let postData = (try? JSONSerialization.data(withJSONObject: parameters, options: [])) else  {
            return bReturn
        }
            
        request.httpBody = postData
        
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
               // var replaced = dataString.replacingOccurrences(of: "\\r\\n", with: "")
                                
//                let data1 = Data(replaced.utf8)
//                print("Recevied Data: \(replaced)")

                do {
                    // make sure this JSON is in the format we expect
                    if let json = try JSONSerialization.jsonObject(with: data, options:.allowFragments) as? [String: Any] {
                        let response_code = json["response_code"] as! Int
                        //sUserID = json["UniqueUserId"] as! String
                        if(response_code==1){
                            bReturn = true
                            if endUrl == "EnrollRFID" {
                                self.isRFIDenrolled = true
                            } else if endUrl == "AuthenticateRFID" {
                                self.isRFIDauthenticated = true
                            }
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
    
    
    func setUserInfo(userName:String, paswrd:String) -> Void {
      //  var sUserID:String=""
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
                        
                        self.sMainUserID = json["UniqueUserId"] as? String
                        self.sUserID = json["UserId"] as? String
                        self.sCompanyID = json["CompanyId"] as? String
                        self.sUsername = userName
                        self.sPassword = paswrd
                        DispatchQueue.main.async {
                            self.UserName.stringValue = self.sUsername
                            self.txtUsername.stringValue = ""
                            self.txtPassword.stringValue = ""
                            self.getAuthXSettings()
                            self.getAuthXFactorsList()
                            self.closeRightSideBar()
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
        //return sUserID;
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
        alert.addButton(withTitle: "ok")
        alert.runModal()
    }
    
    func add_app_setting() -> Bool{
        
        var UpdatedContent:String=""
        let fileURL = NSURL(string: "file:///Users/Shared/authx_security.ini")
        
        do {
            var newUser:String = self.sAppID + "," + self.sAppKey + "," + self.sAppURL
            newUser = newUser + "," + txtUsername.stringValue + "," + txtPassword.stringValue
            UpdatedContent.append(newUser)
            try UpdatedContent.write(to: fileURL! as URL, atomically: false, encoding: .utf8)
        }
        catch {/* error handling here */}
        
        return true;
    }
    
    @IBAction func submit_password_click(_ sender: Any) {
        let success = authenticateLocalUser(username: txtUsername.stringValue, password: txtPassword.stringValue)
        
        if !success {
            dialogOK(question: "User Authenticate", text: "Invalid username/password.", alterStyle:"error")
            return
        }
        else
        {
            self.add_app_setting()
            setUserInfo(userName: self.txtUsername.stringValue, paswrd: self.txtPassword.stringValue)
        }
    }
    
    @IBAction func cancel_password_click(_ sender: Any) {
        self.txtUsername.stringValue = ""
        self.txtPassword.stringValue = ""
        self.closeRightSideBar()
    }
    
    @IBAction func submit_pin_click(_ sender: Any) {
       // getUserID(userName: sUsername)
        let bReturn = getAuth(endUrl: "Authenticate", userID: sMainUserID, authID: txtPin.stringValue)
        if(!bReturn)
        {
            print("authentication failed")
            self.infoMsg.isHidden=false
            self.infoMsg.textColor = NSColor.red
            self.infoMsg.stringValue = "PIN authentication failed."
            
        } else {
            self.infoMsg.isHidden=false
            self.infoMsg.textColor = NSColor.black
            self.infoMsg.stringValue = "PIN authentication done.Logging you in please wait."
        }
    }
    
    @IBAction func cancel_pin_click(_ sender: Any) {
       // tabPassword.isHidden=false
        tabPin.isHidden=true
        tabRFID.isHidden=true
        self.infoMsg.stringValue = ""
        self.authModeImageView.image = nil
        self.instructionMsg.stringValue = ""
    }
    
    func displayedPushAuthInstructions(completion: @escaping (Bool)->()) {
        DispatchQueue.main.async {
            self.infoMsg.stringValue = ""
            self.authModeImageView.image = NSImage(named: "Push_ICO")
            self.instructionMsg.stringValue = "Respond to the push notification on your phone"
            completion(true)
        }
    }
    
    @objc func AuthenticatePush() {
        // getUserID(userName: sUsername)
        let bReturn = self.getAuth(endUrl: "Authenticate", userID: self.sMainUserID, authID: "PUSH")
         if(!bReturn)
         {
             print("authentication failed")
             self.infoMsg.isHidden=false
             self.infoMsg.textColor = NSColor.red
             self.infoMsg.stringValue = "PUSH authentication failed."
             
         } else {
             self.infoMsg.isHidden=false
             self.infoMsg.textColor = NSColor.black
             self.infoMsg.stringValue = "PUSH authentication done.Logging you in please wait."
         }
    }
    
    @IBAction func push_click(_ sender: Any) {
       
        self.displayedPushAuthInstructions(completion: { displayed in
            if displayed == true {
                self.perform(#selector(self.AuthenticatePush), with: nil, afterDelay: 0.2)
            }
        })
       
    }
    
    @IBAction func pin_click(_ sender: Any) {
       // tabPassword.isHidden=true
        tabPin.isHidden=false
        tabRFID.isHidden=true
        self.infoMsg.stringValue = ""
        self.authModeImageView.image = NSImage(named: "PIN_ICO")
        self.instructionMsg.stringValue = "Enter PIN"
    }
    
    @IBAction func passcode_click(_ sender: Any) {
        tabPin.isHidden=false
        tabRFID.isHidden=true
        self.infoMsg.stringValue = ""
        self.authModeImageView.image = NSImage(named: "PIN_ICO")
        self.instructionMsg.stringValue = "Enter Passcode"
    }
    
    func displayedPhoneCallingAuthInstructions(completion: @escaping (Bool)->()) {
        DispatchQueue.main.async {
            self.tabPin.isHidden=false
            self.tabRFID.isHidden=true
            self.infoMsg.stringValue = ""
            self.authModeImageView.image = NSImage(named: "PIN_ICO")
            self.instructionMsg.stringValue = "Enter the PIN from your phone call"
            completion(true)
        }
    }
    
    @objc func AuthenticatePhoneCall() {
        // getUserID(userName: sUsername)
        let bReturn = self.getAuth(endUrl: "Authenticate", userID: self.sMainUserID, authID: "CALL")
         if(!bReturn)
         {
             print("call failed")
         } else {
             print("call sent")
         }
    }
    
    @IBAction func call_click(_ sender: Any) {
        self.displayedPhoneCallingAuthInstructions { displayed in
            if displayed == true {
                self.perform(#selector(self.AuthenticatePhoneCall), with: nil, afterDelay: 0.2)
            }
        }
    }
    
    func displayedPhoneSMSAuthInstructions(completion: @escaping (Bool)->()) {
        DispatchQueue.main.async {
            self.tabPin.isHidden=false
            self.tabRFID.isHidden=true
            self.infoMsg.stringValue = ""
            self.authModeImageView.image = NSImage(named: "PIN_ICO")
            self.instructionMsg.stringValue = "Enter the PIN from your phone"
            completion(true)
        }
    }
    
    @objc func AuthenticatePhoneSMS() {
        // getUserID(userName: sUsername)
        let bReturn = self.getAuth(endUrl: "Authenticate", userID: self.sMainUserID, authID: "SMS")
         if(!bReturn)
         {
             print("sms failed")
         } else {
             print("sms sent")
         }
    }
    
    @IBAction func sms_click(_ sender: Any) {
        self.displayedPhoneSMSAuthInstructions { displayed in
            if displayed == true {
                self.perform(#selector(self.AuthenticatePhoneSMS), with: nil, afterDelay: 0.2)
            }
        }
    }
    
    func grantPermissions() {
        if !IOHIDRequestAccess(kIOHIDRequestTypeListenEvent) {
            //print("Not granted input monitoring")
            sRFIDStatus.stringValue = "Not granted input monitoring"
        } else {
            //print("Granted input monitoring")
            sRFIDStatus.stringValue = "Granted input monitoring"
            self.startTimer()
        }
    }
    
    @IBAction func rfid_click(_ sender: Any) {
        //tabPassword.isHidden=true
        tabPin.isHidden=true
        tabRFID.isHidden=false
        grantPermissions()
        self.infoMsg.stringValue = ""
        self.instructionMsg.stringValue = "Tap your Card"
        self.authModeImageView.image = NSImage(named: "RFID_ICO")
    }
    
    @IBAction func rfid_cancel_click(_ sender: Any) {
        
       // tabPassword.isHidden=false
        tabPin.isHidden=true
        tabRFID.isHidden=true
        self.infoMsg.stringValue = ""
        self.instructionMsg.stringValue = ""
        self.authModeImageView.image = nil
        self.stopTimer()
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
            
          //  nRFID = GetActiveRFID()
            var sOutFound:String = shell("/Users/Shared/activerfid --getid")
            
            if sOutFound.contains("-")
            {
                sRFIDStatus.textColor = NSColor.red
                sRFIDStatus.stringValue = sOutFound
                
                sOutFound="1001"
            }
            
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
               // sRFIDStatus.textColor = NSColor.green
                sRFIDStatus.stringValue = "ID found start authentication please wait."
                
               // getUserID(userName: sUsername)
                
                if let rfID = nRFID {
                    
                    let bReturn = self.getAuth(endUrl: "EnrollRFID", userID: self.sMainUserID, authID: String(rfID))
                   // let bReturn = self.getAuth(endUrl: "AuthenticateRFID", userID: self.sMainUserID, authID: rfID)


                    if isRFIDenrolled {
                        
                        if(!bReturn)
                        {
                            self.infoMsg.isHidden=false
                            self.infoMsg.textColor = NSColor.red
                            self.infoMsg.stringValue = "RFID enrollment failed."
                            
                        } else {
                            self.infoMsg.isHidden=false
                            self.infoMsg.textColor = NSColor.black
                            self.infoMsg.stringValue = "RFID enrollment done"
                        }
                                            
                    } else if isRFIDauthenticated {
                        
                        if(!bReturn)
                        {
                            print("authentication failed")
                            self.infoMsg.isHidden=false
                            self.infoMsg.textColor = NSColor.red
                            self.infoMsg.stringValue = "RFID authentication failed."
                            
                        } else {
                            self.infoMsg.isHidden=false
                            self.infoMsg.textColor = NSColor.black
                            self.infoMsg.stringValue = "RFID authentication done.Logging you in please wait."
                        }
                     }
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


extension AuthxSignIn: NSSplitViewDelegate {
    
    func splitView(_ splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        if subview == self.leftView {
            return true
        }
        return false
    }
    
}


