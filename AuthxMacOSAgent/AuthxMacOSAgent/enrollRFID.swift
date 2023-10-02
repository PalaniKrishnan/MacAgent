//
//  enrollRFID.swift
//  AuthxMacOSAgent
//
//  Created by Admin on 01.01.2023.
//

import Cocoa
import Foundation
import OpenDirectory

class enrollRFID: NSWindowController {
    
    @IBOutlet weak var txtRFID: NSTextField!
    @IBOutlet weak var sRFIDStatus: NSTextField!
    
    var sAppID:String!
    var sAppKey:String!
    var sAppURL:String!
    
    var sAppHost:String!
    var sAppAPI:String!
    
    var sUserUID:String!
    var sUserID:String!
    var sCompanyID:String!
    var nRFID:Int32!
    var timer: Timer?
    var bTResult=false
    var sRFID:String!="0"
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.center()
        self.startTimer()
    }
    
    func enrollRFID() -> Bool {
        var bReturn:Bool=false
        let APIUrl = self.sAppAPI + "EnrollRFID"
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
       
        let bodyContent = "{\"user_name\":\""+sUserUID+"\",\"UserId\":\""+sUserID+"\",\"CompanyId\":\""+sCompanyID+"\",\"correlation_id\":\""+guid+"\",\"authentication_id\":\""+String(nRFID)+"\",\"device_data\":{\"OS\":\"Windows10\",\"OsVersion\":\"10.0.19044\",\"Certify_App_Version\":\"2.3.367.0\",\"MachineName\":\"testmachine\",\"local_network_name\":\"2.3.367.0\",\"local_network_ip\":\"2.3.367.0\"}}"
        
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
    
    @objc func loop() {

        if(self.bTResult==false)
        {
                        
            var sOutFound:String = shell("/Users/Shared/getrfid --getid")
            if sOutFound.contains("-")
            {
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
                sRFIDStatus.textColor = NSColor.green
                sRFIDStatus.stringValue = "ID found start enrolling please wait."
                
                if(enrollRFID())
                {
                    dialogOK(question: "RFID card added", text: "Information", alterStyle: "info")
                    self.window?.close()
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
    // --------------------------------------------------------------------------------
    
    func stopTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    @IBAction func add_rfid_btn_action(_ sender: Any) {
     
        if(enrollRFID())
        {
            dialogOK(question: "RFID card added", text: "Information", alterStyle: "info")
            self.window?.close()
        }

    }
    
    @IBAction func close_btn_action(_ sender: Any) {
        self.window?.close()
    }
}
