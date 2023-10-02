//
//  enrollRFID.swift
//  AuthxMacOSAgent
//
//  Created by Admin on 01.01.2023.
//

import Cocoa
import Foundation
import OpenDirectory

class enrollPhone: NSWindowController {
    
    var sAppID:String!
    var sAppKey:String!
    var sAppURL:String!
    
    var sAppHost:String!
    var sAppAPI:String!
    
    var sUserUID:String!
    var sUserID:String!
    var sCompanyID:String!
    var sQRCodeEnc:String!
    var timer: Timer?
    var bTResult=false
    
    @IBOutlet weak var nsQRCode: NSImageView!
            
    override func windowDidLoad() {
        super.windowDidLoad()
                // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        self.window?.center()
        
        
        let contentArr = sAppURL.components(separatedBy: ".")
        let companyName = contentArr[0].replacingOccurrences(of: "https://", with: "")
        sQRCodeEnc = getcodeid() + "*" + companyName
        nsQRCode.image = generateQRCode(from: sQRCodeEnc!, from: 114.00, from: 108.00)
        self.startTimer()
    }
    
    func generateQRCode(from string: String,from width:CGFloat,from height:CGFloat) -> NSImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let qrcodeImage = filter.outputImage
            let scaleX = width / (qrcodeImage?.extent.size.width)!
            let scaleY = height / (qrcodeImage?.extent.size.height)!
            let transformedImage = qrcodeImage?.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
            let rep: NSCIImageRep = NSCIImageRep(ciImage:transformedImage!)
            let nsImage: NSImage = NSImage(size: rep.size)
            nsImage.addRepresentation(rep)
            return nsImage;
        }
        
        return nil
    }
    
    func getcodeid() -> String {
        var sReturn:String=""
        let APIUrl = self.sAppAPI + "GetCodeId"
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
                sReturn=""
                //return ""
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
                        let UserStatus = json["Code"] as! Int
                        //sUserID = json["UniqueUserId"] as! String
                        if(UserStatus==1){
                            sReturn=json["CodeId"] as! String
                        }
                        else
                        {
                            sReturn=""
                        }
                        
                        defer { sem.signal() }
                        
                    }
                } catch let error as NSError {
                    defer { sem.signal() }
                    sReturn=""
                    //print("Failed to load: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
        sem.wait()
        return sReturn;
    }
    
    func getPhoneForUser() -> Bool {
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
                        if(UserStatus==1){
                            bReturn = true
                        }
                        else
                        {
                            bReturn = false
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
        else if(alterStyle=="warn"){
                alert.alertStyle = NSAlert.Style.warning
        }
                
        alert.addButton(withTitle: "OK")
               
        alert.runModal()
    }
    
    @objc func loop() {

        if(self.bTResult==false)
        {
            bTResult = getPhoneForUser()
        }
        else
        {
            self.bTResult=false;
            self.stopTimer()
            dialogOK(question: "Information", text: "Mobile successfully added", alterStyle: "info")
            NotificationCenter.default.post(name: Notification.Name.Action.CallVC1Method, object: ["command": "load_phone_factors"])
            super.close()
        }
    }
    func startTimer() {
        
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.loop), userInfo: nil, repeats: true)
        }
    }
    // --------------------------------------------------------------------------------
    
    func stopTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    @IBAction func close_btn_action(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name.Action.CallVC1Method, object: ["command": "load_factors"])
        self.stopTimer()
        self.window?.close()
    }
    
    @IBAction func nsRFID_action(_ sender: Any) {
        
    }
}
