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

class loginWindow: NSWindowController {
    
    public var username : String = ""
    public var usertype : String = ""
    public var domain : String = ""
    // --------------------------------------------------------------------------------
   
    
    @IBOutlet weak var txtUserName: NSTextField!
    
    @IBOutlet weak var txtPassword: NSSecureTextField!
    // --------------------------------------------------------------------------------
    
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
    // --------------------------------------------------------------------------------
    
    func dialogOKCancel(question: String, text: String) -> Void {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = NSAlert.Style.critical
        alert.addButton(withTitle: "ok")
        alert.runModal()
    }
    // --------------------------------------------------------------------------------
    
    @IBAction func ok_click(_ sender: Any) {
                
        let success = authenticateLocalUser(username: txtUserName.stringValue, password: txtPassword.stringValue)
        
        if !success {
            dialogOKCancel(question: "User Authenticate", text: "Invalid username/password.")
            return
        }
        else
        {
            NotificationCenter.default.post(name: Notification.Name.Action.CallVC1Method, object: ["command": "save_setting","password": txtPassword.stringValue,"username" : txtUserName.stringValue])
            super.close()
        }
        
    }
    // --------------------------------------------------------------------------------

    @IBAction func cancel_click(_ sender: Any) {
        super.close()
    }
    // --------------------------------------------------------------------------------

    override func windowDidLoad() {
        super.windowDidLoad()
                // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        self.window?.center()
    }
    
}
// --------------------------------------------------------------------------------
