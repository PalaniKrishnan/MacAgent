//
//  ViewController.swift
//  zKeyRegistration
//
//  Created by Shahzad on 10/10/19.
//  Copyright © 2019 Shahzad. All rights reserved.
//


import Cocoa
import CoreServices
import Collaboration
import OpenDirectory

class ViewController: NSViewController {
    
    @IBOutlet weak var txtUser: NSTextField!
    @IBOutlet weak var txtPassword: NSSecureTextField!
    
    public var usertype : String = "local"
    public var domain : String = ""
    
    var nAuthxSignIn:AuthxSignIn?=nil;
    var nauthModes:authModes?=nil;
    
    var sAppID:String!
    var sAppKey:String!
    var sAppURL:String!
    
    var sAppHost:String!
    var sAppAPI:String!
    
    var sUsername:String!
    var sUserUID:String!
    var sUserID:String!
    var sCompanyID:String!
    var guid = NSUUID().uuidString.lowercased()

    func setUserInfo(userName:String) -> Void {
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
                        
                        self.sUserUID = json["UniqueUserId"] as! String
                        self.sUserID = json["UserId"] as! String
                        self.sCompanyID = json["CompanyId"] as! String
                                                
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
                    self.sAppURL = cols[2]
                    let splitedArr = cols[2].components(separatedBy: "-")
                    if splitedArr.count > 1 {
                        let arrayWithHost = splitedArr[1].components(separatedBy: ".")
                        if arrayWithHost.count > 2 {
                            self.sAppHost = arrayWithHost[0]
                            self.sAppAPI = splitedArr[0]+"."+arrayWithHost[1]+"."+arrayWithHost[2]
                            self.view.window?.makeFirstResponder(self.txtUser)
                        }
                    }
                }
            }
        }
        catch {/* error handling here */}
        
        return bReturn
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load_app_setting()
    }
    
    
    override func viewDidAppear() {
        self.view.window?.center()
        //self.view.window?.makeFirstResponder(txtUser)
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
            newUser = newUser + "," + txtUser.stringValue + "," + txtPassword.stringValue
            UpdatedContent.append(newUser)
            try UpdatedContent.write(to: fileURL! as URL, atomically: false, encoding: .utf8)
        }
        catch {/* error handling here */}
        
        return true;
    }
    
    @IBAction func rbtnSave_click(_ sender: Any) {

        let success = authenticateLocalUser(username: txtUser.stringValue, password: txtPassword.stringValue)
        
        if !success {
            dialogOK(question: "User Authenticate", text: "Invalid username/password.", alterStyle:"error")
            return
        }
        else
        {
            setUserInfo(userName:txtUser.stringValue)
//            self.nauthModes = authModes(windowNibName: "authModes" )
//            self.nauthModes?.sUsername = txtUser.stringValue
//
//            self.nauthModes?.sUserUID = self.sUserUID
//            self.nauthModes?.sUserID = self.sUserID
//            self.nauthModes?.sCompanyID = self.sCompanyID
//
//            self.nauthModes?.sAppID = self.sAppID
//            self.nauthModes?.sAppKey = self.sAppKey
//            self.nauthModes?.sAppURL = self.sAppURL
//            self.nauthModes?.sAppAPI = self.sAppAPI
//            self.nauthModes?.sAppHost = self.sAppHost
            add_app_setting()
            
            self.nAuthxSignIn = AuthxSignIn(windowNibName: "AuthxSignIn")
            self.nAuthxSignIn?.sUsername = txtUser.stringValue
            self.nAuthxSignIn?.sPassword = txtPassword.stringValue
             self.nAuthxSignIn?.showWindow (self)
            self.view.window?.orderOut(self)
            self.view.window?.close()
            
        }
        
        //var nActiveID:Int = Int(GetRFIDActiveID());
        
        /*if(txtAppID.stringValue.isEmpty)
        {
            dialogOK(question: "Warning", text: "Please enter Application ID.",alterStyle:"error")
            return
        }
        else if(txtAppKey.stringValue.isEmpty)
        {
            dialogOK(question: "Warning", text: "Please enter Application Key.",alterStyle:"error")
            return
        }
        else if(txtAppURL.stringValue.isEmpty)
        {
            dialogOK(question: "Warning", text: "Please enter Application URL.",alterStyle:"error")
            return
        }
        
        //add_app_setting()
        //dialogOK(question: "Information", text: "Application setting saved.",alterStyle:"info")
        //NSApplication.shared.terminate(self)
        
        self.nLoginWindow = loginWindow(windowNibName: "loginWindow" )
        self.nLoginWindow?.usertype = "local"
        self.nLoginWindow?.showWindow (self)
         */
    }
    
    
    @IBAction func rbtnClose_click(_ sender: Any) {
        NSApplication.shared.terminate(self)
        
        //self.nAuthxSignIn = AuthxSignIn(windowNibName: "AuthxSignIn" )
        //self.nAuthxSignIn?.showWindow (self)
        //self.nAuthxSignIn?.becomeFirstResponder()
        
    }
}


