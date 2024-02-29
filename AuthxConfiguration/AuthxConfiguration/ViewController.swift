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
    
    @IBOutlet weak var txtAppID: NSTextField!
    @IBOutlet weak var txtAppKey: NSTextField!
    @IBOutlet weak var txtAppURL: NSTextField!
    var nAuthxSignIn:AuthxSignIn?=nil;
    var nLoginWindow:loginWindow?=nil;
    var CurrentXMLItem:String?=""
    
    var sAppID:String?=""
    var sAppKey:String?=""
    var sAppURL:String?=""
    var sUserName:String?=""
    var sPassword:String?=""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load_app_setting()
        
    }
    
    override func viewDidAppear() {
        self.view.window?.center()
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
                    self.txtAppID.stringValue=cols[0]
                }
                if (!cols[1].isEmpty)
                {
                    self.txtAppKey.stringValue=cols[1]
                }
                if (!cols[2].isEmpty)
                {
                    self.txtAppURL.stringValue=cols[2]
                }
                if (!cols[3].isEmpty)
                {
                    self.sUserName=cols[3]
                }
                if (!cols[4].isEmpty)
                {
                    self.sPassword=cols[4]
                }
            }
        }
        catch {/* error handling here */}
        
        return bReturn
    }
    
    @IBAction func rbtnImportConfigFile_click(_ sender: Any) {
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a file| Our Code World";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.allowsMultipleSelection = false;
        dialog.canChooseDirectories = false;
        dialog.allowedFileTypes        = ["xml"];

        dialog.prompt = "Import"
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file

            if (result != nil) {
                do {
                let fileName: String = "file://" + result!.path
                let fileURL = NSURL(string: fileName)
                let fileContent = try String(contentsOf: fileURL! as URL, encoding: .utf8)
                var data: Data? = fileContent.data(using: .utf8)
                let parser = XMLParser(data: data!)
                let delegate = ViewController()
                parser.delegate = delegate
                //call the method to parse
                var result: Bool? = parser.parse()
                parser.shouldResolveExternalEntities = true
                    txtAppID.stringValue = delegate.sAppID!
                    txtAppKey.stringValue = delegate.sAppKey!
                    txtAppURL.stringValue = delegate.sAppURL!
                }
                catch{}
                
                // path contains the file path e.g
                // /Users/ourcodeworld/Desktop/file.txt
            }
            
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    @IBAction func rbtnSave_click(_ sender: Any) {
        
        if(txtAppID.stringValue.isEmpty)
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
        
        add_app_setting()
        dialogOK(question: "Information", text: "Application setting saved.",alterStyle:"info")
        NSApplication.shared.terminate(self)
        
        //self.nLoginWindow = loginWindow(windowNibName: "loginWindow" )
        //self.nLoginWindow?.usertype = "local"
        //self.nLoginWindow?.showWindow (self)
    }
    
    
    @IBAction func rbtnClose_click(_ sender: Any) {
        NSApplication.shared.terminate(self)
        
//        self.nAuthxSignIn = AuthxSignIn(windowNibName: "AuthxSignIn" )
//        self.nAuthxSignIn?.showWindow (self)
//        self.nAuthxSignIn?.becomeFirstResponder()
        
    }
    
    func add_app_setting() -> Bool{
        
        var UpdatedContent:String=""
        let fileURL = NSURL(string: "file:///Users/Shared/authx_security.ini")
        
        do {
            var newUser:String = txtAppID.stringValue + "," + txtAppKey.stringValue + "," + txtAppURL.stringValue
            newUser = newUser + "," + sUserName! + "," + sPassword!
            UpdatedContent.append(newUser)
            try UpdatedContent.write(to: fileURL! as URL, atomically: false, encoding: .utf8)
        }
        catch {/* error handling here */}
        
        return true;
    }
}

extension Notification.Name {
    struct Action {
        //notification name
        static let CallVC1Method = Notification.Name("CallVC1Method")
    }
}

extension ViewController: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
    CurrentXMLItem = elementName
        print("CurrentElementl: [\(elementName)]")
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        if(CurrentXMLItem=="ApplicationId")
        {
            self.sAppID = string
        }
        
        if(CurrentXMLItem=="ApplicationKey")
        {
            self.sAppKey = string
        }
        
        if(CurrentXMLItem=="AuthenticationServerEndPoint")
        {
            self.sAppURL = string
        }
        
        print("foundCharacters: [\(string)]")
    }
}
