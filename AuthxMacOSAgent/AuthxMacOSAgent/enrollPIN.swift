//
//  enrollRFID.swift
//  AuthxMacOSAgent
//
//  Created by Admin on 01.01.2023.
//

import Cocoa
import Foundation
import OpenDirectory

class enrollPIN: NSWindowController {
    
    @IBOutlet weak var txtPIN: NSTextField!
    
    var sAppID:String!
    var sAppKey:String!
    var sAppURL:String!
    
    var sAppHost:String!
    var sAppAPI:String!
    
    var sUserUID:String!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.center()
    }
    
    func enrollPIN() -> Bool {
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
        let bodyContent = "{\"unique_id\":\""+sUserUID+"\",\"Pin\":"+txtPIN.stringValue+",\"PinStatus\":true}"
        
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
    
    @IBAction func add_pin_btn_action(_ sender: Any) {
     
        if(enrollPIN())
        {
            dialogOK(question: "Pin added", text: "Information", alterStyle: "info")
            self.window?.close()
        }

    }
    
    @IBAction func close_btn_action(_ sender: Any) {
        self.window?.close()
    }
}
