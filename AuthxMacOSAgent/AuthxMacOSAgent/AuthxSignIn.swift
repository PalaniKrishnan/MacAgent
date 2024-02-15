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
import Security.AuthorizationPlugin
import SecurityInterface

enum AuthFactors: Int {
    case Password = 0
    case Finger = 1
    case Face = 2
    case PalmPush = 3
    case Palm = 4
    case FacePush = 5
    case Push = 6
    case Totp = 7
    case Rfid = 10
    case Sms = 11
    case Call = 12
    case HardwareToken = 14
    case SoftwareToken = 15
    case RemoteLock = 17
    case Pin = 21
}

class AuthxSignIn: NSWindowController, NSTextFieldDelegate {
    
    
    var mechCallbacks: AuthorizationCallbacks?
    var mechEngine: AuthorizationEngineRef?
    var mechView: SFAuthorizationPluginView?
    
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
    
    @IBOutlet weak var appContainerWindow: AppWindow!

    @IBOutlet weak var txtUsername: NSTextField!
    @IBOutlet weak var txtPassword: NSTextField!
    
    @IBOutlet weak var txtPin1: NSSecureTextField!
    @IBOutlet weak var txtPin2: NSSecureTextField!
    @IBOutlet weak var txtPin3: NSSecureTextField!
    @IBOutlet weak var txtPin4: NSSecureTextField!
    @IBOutlet weak var txtPin5: NSSecureTextField!
    @IBOutlet weak var txtPin6: NSSecureTextField!
    
    private var digit: Int?


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
    var companyLogoImage: NSImage?

    @IBOutlet weak var rfidButton: NSButton!
    @IBOutlet weak var pushButton: NSButton!
    @IBOutlet weak var totpButton: NSButton!
    @IBOutlet weak var pinButton: NSButton!
    @IBOutlet weak var smsButton: NSButton!
    @IBOutlet weak var callButton: NSButton!
    
    @IBOutlet weak var pinCancelButton: NSButton!
    @IBOutlet weak var localAuthSubmitButton: NSButton!
    @IBOutlet weak var localAuthCancelButton: NSButton!

    var nRFID:Int32!
    var timer: Timer?
    var bTResult=false
    var sRFID:String!="0"
    var isRFIDenrolled = false

    @IBOutlet weak var sRFIDStatus: NSTextField!

    var guid = NSUUID().uuidString.lowercased()
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
//        self.window?.level = .screenSaver
//        self.window?.orderFrontRegardless()
//        self.window?.canBecomeVisibleWithoutLogin=true
//        
//        self.window?.titlebarAppearsTransparent = true
//        self.window?.isMovable = false
//        
//        self.window?.makeKeyAndOrderFront(self)
        
        txtPin1.delegate = self
        txtPin2.delegate = self
        txtPin3.delegate = self
        txtPin4.delegate = self
        txtPin5.delegate = self
        txtPin6.delegate = self
                                 
        self.pinCancelButton.wantsLayer = true
        self.pinCancelButton.layer?.borderColor = NSColor.white.cgColor
        self.pinCancelButton.layer?.borderWidth = 1
        self.pinCancelButton.layer?.cornerRadius = 5
        
        self.localAuthSubmitButton.wantsLayer = true
        self.localAuthSubmitButton.layer?.borderColor = NSColor.white.cgColor
        self.localAuthSubmitButton.layer?.borderWidth = 1
        self.localAuthSubmitButton.layer?.cornerRadius = 5
        
        self.localAuthCancelButton.wantsLayer = true
        self.localAuthCancelButton.layer?.borderColor = NSColor.white.cgColor
        self.localAuthCancelButton.layer?.borderWidth = 1
        self.localAuthCancelButton.layer?.cornerRadius = 5
        
        self.leftView.wantsLayer = true
        self.leftView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.6).cgColor
        self.rightView.wantsLayer = true
        self.rightView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.6).cgColor
        
        load_app_setting()

        tabPin.isHidden=true
        tabRFID.isHidden=true
        txtUsername.becomeFirstResponder()
        
        self.getAuthXSettings()
        self.getAuthXFactorsList()
        self.closeLeftSidebar()
        self.closeRightSideBar()
        self.logoUpdateListener()
        self.rfid_click(self)
    }
    
    func logoUpdateListener() {
        appContainerWindow.companyLogoUpdate = {
            DispatchQueue.main.async {
                self.appContainerWindow.companyLogoButton.image = self.companyLogoImage
            }
        }
    }
    
    func moveMouseFocusBackward(textField:NSTextField) {
        switch textField {
        case txtPin2:
            txtPin2.resignFirstResponder()
            txtPin1.becomeFirstResponder()
        case txtPin3:
            txtPin3.resignFirstResponder()
            txtPin2.becomeFirstResponder()
        case txtPin4:
            txtPin4.resignFirstResponder()
            txtPin3.becomeFirstResponder()
        case txtPin5:
            txtPin5.resignFirstResponder()
            txtPin4.becomeFirstResponder()
        case txtPin6:
            txtPin6.resignFirstResponder()
            txtPin5.becomeFirstResponder()
        default:
            break
        }
    }
    
    func moveMouseFocusForward(textField:NSTextField) {
        switch textField {
        case txtPin1:
            txtPin1.resignFirstResponder()
            txtPin2.becomeFirstResponder()
        case txtPin2:
            txtPin2.resignFirstResponder()
            txtPin3.becomeFirstResponder()
        case txtPin3:
            txtPin3.resignFirstResponder()
            txtPin4.becomeFirstResponder()
        case txtPin4:
            txtPin4.resignFirstResponder()
            txtPin5.becomeFirstResponder()
        case txtPin5:
            txtPin5.resignFirstResponder()
            txtPin6.becomeFirstResponder()
        case txtPin6:
            txtPin6.resignFirstResponder()
            guard !txtPin1.stringValue.isEmpty, !txtPin2.stringValue.isEmpty, !txtPin3.stringValue.isEmpty, !txtPin4.stringValue.isEmpty, !txtPin5.stringValue.isEmpty, !txtPin6.stringValue.isEmpty else {
                return
            }
            let oneTimeCode = String(format: "%@%@%@%@%@%@", txtPin1.stringValue, txtPin2.stringValue,txtPin3.stringValue, txtPin4.stringValue,txtPin5.stringValue, txtPin6.stringValue)
            self.submit_pin_authentication(value: oneTimeCode)
        default:
            break
        }

    }
                          
    func controlTextDidChange(_ obj: Notification) {
        let textField = obj.object as! NSTextField
        print(textField.stringValue)
        if textField.stringValue.isEmpty {
            self.moveMouseFocusBackward(textField: textField)
        } else if (textField.stringValue.count == 1 && Int(textField.stringValue) != nil) {
            self.moveMouseFocusForward(textField: textField)
            } else {
                let firstChar = textField.stringValue.removeFirst()
                if Int(String(firstChar)) != nil {
                    textField.stringValue = String(firstChar)
                    self.moveMouseFocusForward(textField: textField)
                } else {
                    textField.stringValue = ""
                }
            }
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
        self.rfid_click(self)
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
                            print(cols[3])
                            print(cols[4])
                            if (!cols[3].isEmpty) && (!cols[4].isEmpty) {
                                self.sUsername=cols[3]
                                self.sPassword=cols[4]
                                DispatchQueue.main.async {
                                    self.UserName.stringValue = self.sUsername
                                }
                                self.getUserID(userName:self.sUsername)
                            } else {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    exit(-1)
                                }
                            }
                        }
                    }
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
                          self.sUserID = json["UserId"] as? String
                          self.sCompanyID = json["CompanyId"] as? String
                          
                          
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
                        if let response_code = json["code"] as?  Int, response_code == 1 {
                           // self.companyLogoImage = nil
                            if let companyConfiguration = json["companyConfiguration"] as? Dictionary<String,AnyObject>, let companyLogoString = companyConfiguration["companyLogo"] as? String, let logoUrl = URL(string: companyLogoString) {
                                let logoData = try Data(contentsOf: logoUrl)
                                self.companyLogoImage = NSImage(data: logoData)
                                DispatchQueue.main.async {
                                    self.appContainerWindow.companyLogoButton.image = self.companyLogoImage
                                }
                                
                            }
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
                        let response_code = json["Code"] as! Int
                        //sUserID = json["UniqueUserId"] as! String
                        if(response_code==1), let authFactors = json["UserAuthFactor"] as? Array<AnyObject> {
                             print(authFactors)
                            for factorDic in authFactors   {
                                if let authFactorDic = factorDic as? Dictionary<String, Any>, let factor = authFactorDic["AuthFactor"] as? Int, let factorValue = AuthFactors(rawValue: factor) {
                                    DispatchQueue.main.async {
                                        self.enableAuthFactosWith(factor: factorValue)
                                    }
                                }
                            }
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
    }
    
    func enableAuthFactosWith(factor:AuthFactors) {
        switch factor {
        case .Password:
            break
        case .Push:
            pushButton.isHidden = false
            break
        case .Totp:
            totpButton.isHidden = false
            break
        case .Pin:
            pinButton.isHidden = false
            break
        case .Rfid:
            rfidButton.isHidden = false
            self.isRFIDenrolled = true
            break
        case .Sms:
            smsButton.isHidden = false
            break
        case .Call:
            callButton.isHidden = false
            break
        default:
            break
        }
    }
    

     
    func getAuth(endUrl:String, userID:String, authID:String) -> Bool {
        var success:Bool=false
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
            return success
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
                success=false
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
                            success = true
                            if endUrl == "EnrollRFID" {
                                self.rfid_enrollemnt(success: true)
                            } else if endUrl == "AuthenticateRFID" {
                                self.rfid_authentication(success: true)
                            }
                        } else {
                            if endUrl == "EnrollRFID" {
                                self.rfid_enrollemnt(success: false)
                            } else if endUrl == "AuthenticateRFID" {
                                self.rfid_authentication(success: false)
                            }
                        }
                        defer { sem.signal() }
                        
                    }
                } catch let error as NSError {
                    defer { sem.signal() }
                    success=false
                    print("Failed to load: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
        sem.wait()
        return success;
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
    
    
    @IBAction func submit_password_click(_ sender: Any) {
        let userNametempdata = sUsername + "\0"
        let passwordTempdata = sPassword + "\0"
        self.process_login(userName:userNametempdata,passWord:passwordTempdata)
    }
    
    @IBAction func cancel_password_click(_ sender: Any) {
        self.txtUsername.stringValue = ""
        self.txtPassword.stringValue = ""
        self.closeRightSideBar()
    }
    
    func submit_pin_authentication(value:String) {
       // getUserID(userName: sUsername)
        let success = getAuth(endUrl: "Authenticate", userID: sMainUserID, authID: value)
        if(!success)
        {
            print("authentication failed")
            self.infoMsg.isHidden=false
            self.infoMsg.textColor = NSColor.red
            self.infoMsg.stringValue = "PIN authentication failed."
            
        } else {
            self.infoMsg.isHidden=false
            self.infoMsg.textColor = NSColor.black
            self.infoMsg.stringValue = "PIN authentication done.Logging you in please wait."
            let userNametempdata = sUsername + "\0"
            let passwordTempdata = sPassword + "\0"
            self.process_login(userName:userNametempdata,passWord:passwordTempdata)
        }
    }
    
    @IBAction func cancel_pin_click(_ sender: Any) {
       // tabPassword.isHidden=false
        self.txtPin1.stringValue = ""
        self.txtPin2.stringValue = ""
        self.txtPin3.stringValue = ""
        self.txtPin4.stringValue = ""
        self.txtPin5.stringValue = ""
        self.txtPin6.stringValue = ""

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
        let success = self.getAuth(endUrl: "Authenticate", userID: self.sMainUserID, authID: "PUSH")
         if(!success)
         {
             print("authentication failed")
             self.infoMsg.isHidden=false
             self.infoMsg.textColor = NSColor.red
             self.infoMsg.stringValue = "PUSH authentication failed."
             
         } else {
             self.infoMsg.isHidden=false
             self.infoMsg.textColor = NSColor.black
             self.infoMsg.stringValue = "PUSH authentication done.Logging you in please wait."
             let userNametempdata = sUsername + "\0"
             let passwordTempdata = sPassword + "\0"
             self.process_login(userName:userNametempdata,passWord:passwordTempdata)
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
        txtPin1.becomeFirstResponder()
        tabRFID.isHidden=true
        self.infoMsg.stringValue = ""
        self.authModeImageView.image = NSImage(named: "PIN_ICO")
        self.instructionMsg.stringValue = "Enter PIN"
    }
    
    @IBAction func passcode_click(_ sender: Any) {
        tabPin.isHidden=false
        txtPin1.becomeFirstResponder()
        tabRFID.isHidden=true
        self.infoMsg.stringValue = ""
        self.authModeImageView.image = NSImage(named: "PIN_ICO")
        self.instructionMsg.stringValue = "Enter Passcode"
    }
    
    func displayedPhoneCallingAuthInstructions(completion: @escaping (Bool)->()) {
        DispatchQueue.main.async {
            self.tabPin.isHidden=false
            self.txtPin1.becomeFirstResponder()
            self.tabRFID.isHidden=true
            self.infoMsg.stringValue = ""
            self.authModeImageView.image = NSImage(named: "PIN_ICO")
            self.instructionMsg.stringValue = "Enter the PIN from your phone call"
            completion(true)
        }
    }
    
    @objc func AuthenticatePhoneCall() {
        // getUserID(userName: sUsername)
        let success = self.getAuth(endUrl: "Authenticate", userID: self.sMainUserID, authID: "CALL")
         if(!success)
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
            self.txtPin1.becomeFirstResponder()
            self.tabRFID.isHidden=true
            self.infoMsg.stringValue = ""
            self.authModeImageView.image = NSImage(named: "PIN_ICO")
            self.instructionMsg.stringValue = "Enter the PIN from your phone"
            completion(true)
        }
    }
    
    @objc func AuthenticatePhoneSMS() {
        // getUserID(userName: sUsername)
        let success = self.getAuth(endUrl: "Authenticate", userID: self.sMainUserID, authID: "SMS")
         if(!success)
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
       // self.startTimer()
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
    
    func rfid_enrollemnt(success:Bool) {
        DispatchQueue.main.async {
            if(!success)
            {
                self.infoMsg.isHidden=false
                self.infoMsg.textColor = NSColor.red
                self.infoMsg.stringValue = "RFID enrollment failed."
                
            } else {
                self.infoMsg.isHidden=false
                self.infoMsg.textColor = NSColor.black
                self.infoMsg.stringValue = "RFID enrollment done"
                self.isRFIDenrolled = true
                self.rfidButton.isHidden = false
            }
        }
    }
    
    func rfid_authentication(success:Bool) {
        DispatchQueue.main.async {
            if(!success)
            {
                print("authentication failed")
                self.infoMsg.isHidden=false
                self.infoMsg.textColor = NSColor.red
                self.infoMsg.stringValue = "RFID authentication failed."
                
            } else {
                self.infoMsg.isHidden=false
                self.infoMsg.textColor = NSColor.black
                self.infoMsg.stringValue = "RFID authentication done.Logging you in please wait."
                let userNametempdata = self.sUsername + "\0"
                let passwordTempdata = self.sPassword + "\0"
                self.process_login(userName:userNametempdata,passWord:passwordTempdata)
            }
        }
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

            let sOutFound:String = shell("/Users/Shared/authx/readercomm --getid")
            print(sOutFound)
            if sOutFound.contains("Reader not connected")
            {
                sRFIDStatus.textColor = NSColor.red
                sRFIDStatus.stringValue = "Reader not connected"
            } else if sOutFound.contains("No id found"){
                sRFIDStatus.textColor = NSColor.blue
              //  sRFIDStatus.stringValue = sOutFound
                sRFIDStatus.stringValue = "Tap your card."
            } else {
                self.stopTimer()
                
               // nRFID = Int64(sOutFound);//shell("/User/Shared/getrfid --getid")
               // print(String(nRFID))
                
                sRFIDStatus.textColor = NSColor.green
                sRFIDStatus.stringValue = "ID found start authentication please wait."

                let success = self.getAuth(endUrl: !self.isRFIDenrolled ? "EnrollRFID" : "AuthenticateRFID", userID: self.sMainUserID, authID: sOutFound)
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
    
    
    func process_login(userName:String,passWord:String ) {
        
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
              //  self.window?.close()
               // self.backgroundWindow.close()
                //NSApp.stopModal()
            } else {
                self.window?.orderOut(self)
                self.window?.close()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    exit(-1)
                }
            }
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


