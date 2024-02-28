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
    @IBOutlet weak var authCustomView: NSView!

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
    let computerName = ProcessInfo.processInfo.hostName


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
        let bodyContent = "{\"Username\":\""+userName+"\",\"ApplicationKey\":\""+sAppID+"\",\"SecretKey\":\""+sAppKey+"\",\"HostName\":\""+sAppHost+"\",\"SourceApplication\":\"Mac\",\"DeviceInfo\":{\"OS\":\"Windows10\",\"OsVersion\":\"10.0.19044\",\"Certify_App_Version\":\"2.3.367.0\",\"MachineName\":\""+computerName+"\",\"local_network_name\":\"2.3.367.0\",\"local_network_ip\":\"2.3.367.0\"}}"
        
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
                DispatchQueue.main.async {
                    self.authCustomView.isHidden = false
                    self.view.window?.makeFirstResponder(self.txtUser)
                }
                
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
                        
                        self.sUserUID = json["UniqueUserId"] as? String
                        self.sUserID = json["UserId"] as? String
                        self.sCompanyID = json["CompanyId"] as? String
                        self.moveToAuthFactorsWindow()
                        defer { sem.signal() }
                        
                    }
                } catch let error as NSError {
                    defer { sem.signal() }
                    print("Failed to load: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.authCustomView.isHidden = false
                        self.view.window?.makeFirstResponder(self.txtUser)
                    }
                }
            }
        }
        
        task.resume()
        sem.wait()
        //return sUserID;
    }
    
    func loadAppSetting() {
        
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
                                self.setUserInfo(userName:cols[3], paswrd: cols[4])
                            } else {
                                self.authCustomView.isHidden = false
                                self.view.window?.makeFirstResponder(self.txtUser)
                            }
                        }
                    }
                }
            }
        }
        catch {
            
            /* error handling here */
        }
        
    }
    
    func moveToAuthFactorsWindow() {
        DispatchQueue.main.async {
            self.nAuthxSignIn = AuthxSignIn(windowNibName: "AuthxSignIn")
            self.nAuthxSignIn?.showWindow (self)
            self.view.window?.orderOut(self)
            self.view.window?.close()
        }
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
    }
    
    
    override func viewDidAppear() {
        self.view.window?.center()
       // loadAppSetting()
        moveToAuthFactorsWindow()
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
    
    func add_app_setting() -> Bool {
        
        var UpdatedContent:String=""
        let fileURL = NSURL(string: "file:///Users/Shared/authx_security.ini")
        
        do {
            var newUser:String = self.sAppID + "," + self.sAppKey + "," + self.sAppURL
            newUser = newUser + "," + txtUser.stringValue + "," + txtPassword.stringValue
            UpdatedContent.append(newUser)
            try UpdatedContent.write(to: fileURL! as URL, atomically: false, encoding: .utf8)
        }
        catch {/* error handling here */
            return false
        }
        
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
            add_app_setting()
            setUserInfo(userName:txtUser.stringValue, paswrd: txtPassword.stringValue)
        }
        
    }
    
    
    @IBAction func rbtnClose_click(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
}


