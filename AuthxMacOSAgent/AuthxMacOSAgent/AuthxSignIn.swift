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
import AVFoundation
import Vision


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
    
    @IBOutlet private weak var cameraView: NSView!

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
    var accessToken:String!

    public var usertype : String = "local"
    public var domain : String = ""
    
    @IBOutlet weak var txtUser_launch: NSTextField!
    @IBOutlet weak var txtPswd_launch: NSTextField!
    
    @IBOutlet weak var appContainerWindow: AppWindow!

    @IBOutlet weak var txtUsername_networklogon: NSTextField!
    @IBOutlet weak var txtPassword_networklogon: NSTextField!
    
    @IBOutlet weak var txtSecurePin1: NSSecureTextField!
    @IBOutlet weak var txtSecurePin2: NSSecureTextField!
    @IBOutlet weak var txtSecurePin3: NSSecureTextField!
    @IBOutlet weak var txtSecurePin4: NSSecureTextField!
    @IBOutlet weak var txtSecurePin5: NSSecureTextField!
    @IBOutlet weak var txtSecurePin6: NSSecureTextField!
    
    @IBOutlet weak var txtPlainPin1: NSTextField!
    @IBOutlet weak var txtPlainPin2: NSTextField!
    @IBOutlet weak var txtPlainPin3: NSTextField!
    @IBOutlet weak var txtPlainPin4: NSTextField!
    @IBOutlet weak var txtPlainPin5: NSTextField!
    @IBOutlet weak var txtPlainPin6: NSTextField!
    
    private var digit: Int?


    @IBOutlet weak var infoMsg: NSTextField!
    @IBOutlet weak var instructionMsg: NSTextField!
   

    @IBOutlet weak var tabPassword: NSTabView!
    @IBOutlet weak var tabPin: NSTabView!
    @IBOutlet weak var tabRFID: NSTabView!
    
    @IBOutlet weak var splitView: NSSplitView!
    @IBOutlet weak var leftView: NSView!
    @IBOutlet weak var middleView: NSView!
    @IBOutlet weak var rightView: NSView!
    @IBOutlet weak var helpView: NSView!
    @IBOutlet weak var powerSystemEventsView: NSView!
    @IBOutlet weak var faceCaptureView: NSView!

    @IBOutlet weak var UserName: NSTextField!
    @IBOutlet weak var CompanyName: NSTextField!
    @IBOutlet weak var displayTextFieldOnLogonScreen: NSTextField!
    @IBOutlet weak var authModeImageView: NSImageView!
    @IBOutlet weak var rightButton: NSButton!
    @IBOutlet weak var leftButton: NSButton!
    @IBOutlet weak var eyeButton: NSButton!
    @IBOutlet weak var networkLogonButton: NSButton!
    @IBOutlet weak var appLogoBtn: NSButton!
    @IBOutlet weak var powerBtn: NSButton!
    @IBOutlet weak var helpBtn: NSButton!

    var companyLogoImage: NSImage?
    var appBgImage: NSImage?
    var faceImage: NSImage?

    @IBOutlet weak var faceButton: NSButton!
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
    var isRFIDenrolled = false
    var canAllowRfidEnroll = false
    var rfidEnrollIsInProgress = false
    var rfIdentifierStr = ""

    var isSecurePin : Bool = true {
        didSet {
            if isSecurePin {
                eyeButton.image = NSImage(named: "view-icon")
                showSecurePinFields()
                hidePlainPinFields()
            } else {
                eyeButton.image = NSImage(named: "hidepswd")
                showPlainPinFields()
                hideSecurePinFields()
            }
        }
    }
    
    @IBOutlet weak var appVersionField: NSTextField!
    @IBOutlet weak var machineNameField: NSTextField!
    @IBOutlet weak var helpDeskField: NSTextField!

    @IBOutlet weak var authCustomView: NSView!

    let systemEvents = RestartShutdownLogout()

    var guid = NSUUID().uuidString.lowercased()
    let computerName = ProcessInfo.processInfo.hostName
    
    var app_delegate:AppDelegate?
    var appFontColour:NSColor = .black
    var applicationName:String = ""
    var defaults = NSUserDefaultsController.shared.defaults
    
    private var cameraManager: CameraManagerProtocol!
    @IBOutlet weak var faceImageView: NSImageView!
    @IBOutlet weak var retakeButton: NSButton!
    @IBOutlet weak var continueButton: NSButton!
    var overlayFrame: CGRect!

    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.cameraView.backgroundColor = NSColor.white
        self.cameraView.layer?.cornerRadius = 10
        self.cameraView.layer?.masksToBounds = true
                
        do {
            cameraManager = try CameraManager(containerView: self.cameraView)
          cameraManager.delegate = self
        } catch {
          // Cath the error here
          print(error.localizedDescription)
        }
        
        let overlay = createOverlay()
        self.cameraView.addSubview(overlay)
        
        self.helpView.backgroundColor = NSColor.white
        self.helpView.layer?.cornerRadius = 10
        self.helpView.layer?.masksToBounds = true
        
        self.powerSystemEventsView.backgroundColor = NSColor.white
        self.powerSystemEventsView.layer?.cornerRadius = 10
        self.powerSystemEventsView.layer?.masksToBounds = true
        
        self.authCustomView.backgroundColor = NSColor.lightGray
        self.authCustomView.layer?.cornerRadius = 10
        self.authCustomView.layer?.masksToBounds = true
        
        self.faceCaptureView.backgroundColor = NSColor.lightGray
        self.faceCaptureView.layer?.cornerRadius = 10
        self.faceCaptureView.layer?.masksToBounds = true
        

//        self.window?.level = .screenSaver
//        self.window?.orderFrontRegardless()
//        self.window?.canBecomeVisibleWithoutLogin=true
//        
//        self.window?.titlebarAppearsTransparent = true
//        self.window?.isMovable = false
//        
//        self.window?.makeKeyAndOrderFront(self)
        
        txtSecurePin1.delegate = self
        txtSecurePin2.delegate = self
        txtSecurePin3.delegate = self
        txtSecurePin4.delegate = self
        txtSecurePin5.delegate = self
        txtSecurePin6.delegate = self
        
        txtPlainPin1.delegate = self
        txtPlainPin2.delegate = self
        txtPlainPin3.delegate = self
        txtPlainPin4.delegate = self
        txtPlainPin5.delegate = self
        txtPlainPin6.delegate = self
                                 
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
        
        self.load_app_setting()
        self.tabPin.isHidden=true
        self.tabRFID.isHidden=true
        self.txtUsername_networklogon.becomeFirstResponder()

        app_delegate = NSApplication.shared.delegate as? AppDelegate
        app_delegate?.appBecomingActive = {
            self.load_app_setting()
        }
    }
    
    
    func createOverlay() -> NSView {
        let overlayView = NSView(frame: self.cameraView.frame)
        overlayView.backgroundColor = NSColor.black.withAlphaComponent(0.7)

        let path = CGMutablePath()
        overlayFrame = CGRect(x: 50, y: 50, width: overlayView.frame.width-100, height: overlayView.frame.height - 100)
        path.addRoundedRect(in: overlayFrame, cornerWidth: 5, cornerHeight: 5)

        
        path.closeSubpath()
        
        let shape = CAShapeLayer()
        shape.path = path
        shape.lineWidth = 5.0
        shape.strokeColor = NSColor.white.cgColor
        shape.fillColor = NSColor.white.cgColor
        
        overlayView.layer?.addSublayer(shape)
        
        path.addRect(CGRect(origin: .zero, size: overlayView.frame.size))

        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = NSColor.black.cgColor
        maskLayer.path = path
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd

        overlayView.layer?.mask = maskLayer
        overlayView.clipsToBounds = true
        
        return overlayView
    }
    
    
    func add_app_setting() -> Bool {
        
        var UpdatedContent:String=""
        let fileURL = NSURL(string: "file:///Users/Shared/authx_security.ini")
        
        do {
            var newUser:String = self.sAppID + "," + self.sAppKey + "," + self.sAppURL
            newUser = newUser + "," + txtUser_launch.stringValue + "," + txtPswd_launch.stringValue
            UpdatedContent.append(newUser)
            try UpdatedContent.write(to: fileURL! as URL, atomically: false, encoding: .utf8)
        }
        catch {/* error handling here */
            return false
        }
        
        return true;
    }
    
    func resetLogonPage() {
        self.authCustomView.isHidden = false
        self.leftButton.isHidden = true
        self.rightButton.isHidden = true
        self.powerBtn.isHidden = true
        self.helpBtn.isHidden = true
    }
    
    func setLoggedOnSession() {
        self.defaults.setValue(Date(), forKey: "loggedon_date")
        self.authCustomView.isHidden = true
        self.leftButton.isHidden = false
        self.rightButton.isHidden = false
        self.powerBtn.isHidden = false
        self.helpBtn.isHidden = false
    }
    
    @IBAction func rbtnSave_click(_ sender: Any) {

        let success = authenticateLocalUser(username: txtUser_launch.stringValue, password: txtPswd_launch.stringValue)
        
        if !success {
            dialogOK(question: "User Authenticate", text: "Invalid username/password.", alterStyle:"error")
            return
        }
        else if self.rfidEnrollIsInProgress == true {
            self.rfidEnrollIsInProgress = false
            self.setLoggedOnSession()
            self.instructionMsg.stringValue = "Started enrolling, please wait."
            _ = self.getAuth(endUrl: "EnrollRFID", userID: self.sMainUserID, authID: self.rfIdentifierStr)
        } else {
            self.setLoggedOnSession()
            if add_app_setting() {
                load_app_setting()
            }
        }
    }
    
    
    @IBAction func rbtnClose_click(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    func updateUIwithAuthFactors() {
        self.getAuthXSettings()
        self.getAuthXFactorsList()
    }
    
    
    @IBAction func powerBtnClicked(_ sender: Any)  {
        DispatchQueue.main.async {
            self.powerSystemEventsView.isHidden = !self.powerSystemEventsView.isHidden
        }
    }
    
    @IBAction func helpBtnClicked(_ sender: Any)  {
        DispatchQueue.main.async {
            self.helpView.isHidden = false
            if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                self.appVersionField.stringValue = appVersion
                self.machineNameField.stringValue = self.computerName
            }
        }
    }
    
    @IBAction func systemEventBtnClicked(_ sender: Any)  {
        guard let btn = sender as? NSButton else {
            return
        }
        systemEvents.sendSystemEvent(Int32(btn.tag))
    }
    
    
    
    func moveMouseFocusBackward(textField:NSSecureTextField) {
        switch textField {
        case txtSecurePin2:
            txtSecurePin2.resignFirstResponder()
            txtSecurePin1.becomeFirstResponder()
        case txtSecurePin3:
            txtSecurePin3.resignFirstResponder()
            txtSecurePin2.becomeFirstResponder()
        case txtSecurePin4:
            txtSecurePin4.resignFirstResponder()
            txtSecurePin3.becomeFirstResponder()
        case txtSecurePin5:
            txtSecurePin5.resignFirstResponder()
            txtSecurePin4.becomeFirstResponder()
        case txtSecurePin6:
            txtSecurePin6.resignFirstResponder()
            txtSecurePin5.becomeFirstResponder()
        default:
            break
        }
    }
    
    func moveMouseFocusForward(textField:NSSecureTextField) {
        switch textField {
        case txtSecurePin1:
            txtSecurePin1.resignFirstResponder()
            txtSecurePin2.becomeFirstResponder()
        case txtSecurePin2:
            txtSecurePin2.resignFirstResponder()
            txtSecurePin3.becomeFirstResponder()
        case txtSecurePin3:
            txtSecurePin3.resignFirstResponder()
            txtSecurePin4.becomeFirstResponder()
        case txtSecurePin4:
            txtSecurePin4.resignFirstResponder()
            txtSecurePin5.becomeFirstResponder()
        case txtSecurePin5:
            txtSecurePin5.resignFirstResponder()
            txtSecurePin6.becomeFirstResponder()
        case txtSecurePin6:
            txtSecurePin6.resignFirstResponder()
            guard !txtSecurePin1.stringValue.isEmpty, !txtSecurePin2.stringValue.isEmpty, !txtSecurePin3.stringValue.isEmpty, !txtSecurePin4.stringValue.isEmpty, !txtSecurePin5.stringValue.isEmpty, !txtSecurePin6.stringValue.isEmpty else {
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let oneTimeCode = String(format: "%@%@%@%@%@%@", self.txtSecurePin1.stringValue, self.txtSecurePin2.stringValue,self.txtSecurePin3.stringValue, self.txtSecurePin4.stringValue,self.txtSecurePin5.stringValue, self.txtSecurePin6.stringValue)
                self.submit_pin_authentication(value: oneTimeCode)
            }
            
        default:
            break
        }

    }
                          
    func moveMouseFocusForward(textField:NSTextField) {
        switch textField {
        case txtPlainPin1:
            txtPlainPin1.resignFirstResponder()
            txtPlainPin2.becomeFirstResponder()
        case txtPlainPin2:
            txtPlainPin2.resignFirstResponder()
            txtPlainPin3.becomeFirstResponder()
        case txtPlainPin3:
            txtPlainPin3.resignFirstResponder()
            txtPlainPin4.becomeFirstResponder()
        case txtPlainPin4:
            txtPlainPin4.resignFirstResponder()
            txtPlainPin5.becomeFirstResponder()
        case txtPlainPin5:
            txtPlainPin5.resignFirstResponder()
            txtPlainPin6.becomeFirstResponder()
        case txtPlainPin6:
            txtPlainPin6.resignFirstResponder()
            guard !txtPlainPin1.stringValue.isEmpty, !txtPlainPin2.stringValue.isEmpty, !txtPlainPin3.stringValue.isEmpty, !txtPlainPin4.stringValue.isEmpty, !txtPlainPin5.stringValue.isEmpty, !txtPlainPin6.stringValue.isEmpty else {
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let oneTimeCode = String(format: "%@%@%@%@%@%@", self.txtPlainPin1.stringValue, self.txtPlainPin2.stringValue,self.txtPlainPin3.stringValue, self.txtPlainPin4.stringValue,self.txtPlainPin5.stringValue, self.txtPlainPin6.stringValue)
                self.submit_pin_authentication(value: oneTimeCode)
            }
        default:
            break
        }

    }
    
    func moveMouseFocusBackward(textField:NSTextField) {
        switch textField {
        case txtPlainPin2:
            txtPlainPin2.resignFirstResponder()
            txtPlainPin1.becomeFirstResponder()
        case txtPlainPin3:
            txtPlainPin3.resignFirstResponder()
            txtPlainPin2.becomeFirstResponder()
        case txtPlainPin4:
            txtPlainPin4.resignFirstResponder()
            txtPlainPin3.becomeFirstResponder()
        case txtPlainPin5:
            txtPlainPin5.resignFirstResponder()
            txtPlainPin4.becomeFirstResponder()
        case txtPlainPin6:
            txtPlainPin6.resignFirstResponder()
            txtPlainPin5.becomeFirstResponder()
        default:
            break
        }
    }
    
    func copyToPlainPinFields(txtField:NSSecureTextField) {
        switch txtField {
        case txtSecurePin1:
            txtPlainPin1.stringValue = txtField.stringValue
        case txtSecurePin2:
            txtPlainPin2.stringValue = txtField.stringValue
        case txtSecurePin3:
            txtPlainPin3.stringValue = txtField.stringValue
        case txtSecurePin4:
            txtPlainPin4.stringValue = txtField.stringValue
        case txtSecurePin5:
            txtPlainPin5.stringValue = txtField.stringValue
        case txtSecurePin6:
            txtPlainPin6.stringValue = txtField.stringValue
        default:
            break
        }
    }
    
    func copyToSecurePinFields(txtField:NSTextField) {
        switch txtField {
        case txtPlainPin1:
            txtSecurePin1.stringValue = txtField.stringValue
        case txtPlainPin2:
            txtSecurePin2.stringValue = txtField.stringValue
        case txtPlainPin3:
            txtSecurePin3.stringValue = txtField.stringValue
        case txtPlainPin4:
            txtSecurePin4.stringValue = txtField.stringValue
        case txtPlainPin5:
            txtSecurePin5.stringValue = txtField.stringValue
        case txtPlainPin6:
            txtSecurePin6.stringValue = txtField.stringValue
        default:
            break
        }
    }
    
    
    func controlTextDidChange(_ obj: Notification) {
        if !isSecurePin {
            let textField = obj.object as! NSTextField
            print(textField.stringValue)
            if textField.stringValue.isEmpty {
                self.moveMouseFocusBackward(textField: textField)
                self.copyToSecurePinFields(txtField: textField)
            } else if (textField.stringValue.count == 1 && Int(textField.stringValue) != nil) {
                self.moveMouseFocusForward(textField: textField)
                self.copyToSecurePinFields(txtField: textField)
            } else {
                let firstChar = textField.stringValue.removeFirst()
                if Int(String(firstChar)) != nil {
                    textField.stringValue = String(firstChar)
                    self.moveMouseFocusForward(textField: textField)
                    self.copyToSecurePinFields(txtField: textField)
                } else {
                    textField.stringValue = ""
                }
            }
        } else {
            let textField = obj.object as! NSSecureTextField
            print(textField.stringValue)
            if textField.stringValue.isEmpty {
                self.moveMouseFocusBackward(textField: textField)
                self.copyToPlainPinFields(txtField: textField)
            } else if (textField.stringValue.count == 1 && Int(textField.stringValue) != nil) {
                self.moveMouseFocusForward(textField: textField)
                self.copyToPlainPinFields(txtField: textField)
            } else {
                let firstChar = textField.stringValue.removeFirst()
                if Int(String(firstChar)) != nil {
                    textField.stringValue = String(firstChar)
                    self.moveMouseFocusForward(textField: textField)
                    self.copyToPlainPinFields(txtField: textField)
                } else {
                    textField.stringValue = ""
                }
            }
        }
    }
    
    
    func hideSecurePinFields() {
        txtSecurePin1.isHidden = true
        txtSecurePin2.isHidden = true
        txtSecurePin3.isHidden = true
        txtSecurePin4.isHidden = true
        txtSecurePin5.isHidden = true
        txtSecurePin6.isHidden = true
    }
    
    func showSecurePinFields() {
        txtSecurePin1.isHidden = false
        txtSecurePin2.isHidden = false
        txtSecurePin3.isHidden = false
        txtSecurePin4.isHidden = false
        txtSecurePin5.isHidden = false
        txtSecurePin6.isHidden = false
    }
    
    func showPlainPinFields() {
        txtPlainPin1.isHidden = false
        txtPlainPin2.isHidden = false
        txtPlainPin3.isHidden = false
        txtPlainPin4.isHidden = false
        txtPlainPin5.isHidden = false
        txtPlainPin6.isHidden = false
    }
    
    func hidePlainPinFields() {
        txtPlainPin1.isHidden = true
        txtPlainPin2.isHidden = true
        txtPlainPin3.isHidden = true
        txtPlainPin4.isHidden = true
        txtPlainPin5.isHidden = true
        txtPlainPin6.isHidden = true
    }
    
    @IBAction func eyeIconClicked (_ sender: Any) {
        isSecurePin = !isSecurePin
    }
    
    @IBAction func closeHelpClicked (_ sender: Any) {
        self.helpView.isHidden = true
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
    
    @IBAction func networkLogonClicked (_ sender: Any) {
        self.rightSideBarBtnClicked(self.rightButton as Any)
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
      //  self.closeRightSideBar()
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
       // self.closeLeftSidebar()
        let rightSideView = splitView.subviews[2] as NSView
        rightSideView.isHidden = false
        let containerFrame = splitView.frame
        rightSideView.frame.size = NSMakeSize(200, containerFrame.size.height)
        splitView.display()
    }
    
    func load_app_setting() -> Void{
    
        self.closeLeftSidebar()
        self.closeRightSideBar()
        
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
                                self.getUserID()
                                self.updateUIwithAuthFactors()
                            } else {
                                DispatchQueue.main.async {
                                    self.resetLogonPage()
                                }
                            }
                        }
                    }
                }
            }
        }
        catch {/* error handling here */}
    }
    
//    func dialogOKCancel(question: String, text: String) -> Void {
//        let alert = NSAlert()
//        alert.messageText = question
//        alert.informativeText = text
//        alert.alertStyle = NSAlert.Style.critical
//        alert.addButton(withTitle: "ok")
//        alert.runModal()
//    }
 
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

    
    func getUserID() {
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
          
//          var body = Data()
//          let bodyContent = "{\"Username\":\""+sUsername+"\",\"ApplicationKey\":\""+sAppID+"\",\"SecretKey\":\""+sAppKey+"\",\"HostName\":\""+sAppHost+"\",\"SourceApplication\":\"Windows\",\"DeviceInfo\":{\"OS\":\"Windows10\",\"OsVersion\":\"10.0.19044\",\"Certify_App_Version\":\"2.3.367.0\",\"MachineName\":\""+computerName+"\",\"local_network_name\":\"2.3.367.0\",\"local_network_ip\":\"2.3.367.0\"}}"
//          
//          body.append(bodyContent.data(using: String.Encoding.utf8)!)
        
        let deviceData = ["OS":"Microsoft Windows 10 Pro",
                          "OsVersion":"10.0.19045",
                          "Certify_App_Version":"2.4.23.1",
                          "MachineName":computerName,
                          "local_network_name":"CERTIFY",
                          "local_network_ip":"2.3.367.0"
                          ] as [String : AnyObject]
        
        let parameters =  ["Username":sUsername ?? "",
                           "ApplicationKey":self.sAppID,
                           "SecretKey":sAppKey,
                           "HostName":sAppHost,
                           "SourceApplication":"Windows",
                           "DeviceInfo": deviceData] as [String : AnyObject]
        print(url as Any)
        print(parameters)
            
        guard let postData = (try? JSONSerialization.data(withJSONObject: parameters, options: [])) else  {
            return
        }
            
        request.httpBody = postData
        
          
       //   request.httpBody = body
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
                          self.accessToken = json["access_token"] as? String
                          defer { sem.signal() }

                      } else {
                          DispatchQueue.main.async {
                              self.dialogOK(question: "User Authenticate", text: dataString, alterStyle:"error")
                              self.resetLogonPage()
                          }
                      }
                  } catch let error as NSError {
                      defer { sem.signal() }
                      print("Failed to load: \(error.localizedDescription)")
                      DispatchQueue.main.async {
                          self.dialogOK(question: "User Authenticate", text: dataString, alterStyle:"error")
                          self.resetLogonPage()
                      }
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
                          "MachineName":computerName,
                          "AD_Domain":"CERTIFY",
                          "HostName":sAppHost,
                          "Local_IP":nil,
                          "IsDelegatedAccess":false] as [String : AnyObject]
        
        
        let userGeo = ["Ip":nil,"Country":nil,"City":nil,"State":nil] as [String : AnyObject]
        let bioRequest = ["bioIndex":nil] as [String : AnyObject]

        
        let parameters =  ["Username":self.sMainUserID,
                           "UserId":self.sUserID,
                           "CompanyName":nil,
                           "CompanyId":nil,
                           "UserType":"Admin",
                           "ApplicationKey":sAppID,
                           "SecretKey":sAppKey,
                           "Password":nil,
                           "grant_type":nil,
                           "ClientKey":nil,
                           "SessionId":self.accessToken,
                           "Totp":nil,
                           "FacilityAccessCode":nil,
                           "CardId":nil,
                           "AuthFactor":nil,
                           "SourceApplication":"Windows",
                           "EventType":21,
                           "BioRequest":bioRequest,
                           "UserGeographics":userGeo,
                           "DeviceInfo": deviceData] as [String : AnyObject]
        print(url as Any)
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
                            if let companyConfiguration = json["companyConfiguration"] as? Dictionary<String,AnyObject>, let appConfiguration = json["applicationConfiguration"] as?  Dictionary<String,AnyObject>, let advancedConfiguration = appConfiguration["advancedConfiguration"] as? NSArray, let configInfo = advancedConfiguration.firstObject as? Dictionary<String,AnyObject>, let logonBgColor_hex = configInfo["logon_background_color"] as? String, let fontColor_hex = configInfo["font_color"] as? String, let helpText = configInfo["help_text_login_screen"] as? String, let logon_screen_background_url_string = configInfo["logon_screen_background"] as? String, let is_allow_badge_enrollment = configInfo["allow_badge_enrollment"]?.boolValue, let disclaimer_string = configInfo["disclaimer"] as? String, let does_display_powerbtn_loginscreen = configInfo["display_powerbtn_loginscreen"] as? Bool, let does_username_display_on_screen = configInfo["username_display_on_screen"] as? Bool, let password_expiry_hours_minutes = configInfo["password_expiry_hours_minutes"] as? 
                                String, let password_authentication = configInfo["password_authentication"] as? Int, let password_authentication_expiry = configInfo["password_authentication_expiry"] as? Int, let appname = appConfiguration["applicationName"] as? String {
                                print(configInfo)
                                let fontColour = NSColor(hex: fontColor_hex)
                                self.appFontColour = fontColour
                                self.applicationName = appname
                                DispatchQueue.main.async {
                                    if let logged_on_date = self.defaults.value(forKey: "loggedon_date") as? Date {
                                    print(logged_on_date)
                                    let logged_on_days = self.days(from: logged_on_date)
                                    let logged_on_hours =  self.hours(from: logged_on_date)
                                    let logged_on_minutes =  self.minutes(from: logged_on_date)

                                    print(logged_on_days)
                                    let hour_minute_splited = password_expiry_hours_minutes.components(separatedBy: ":")
                                    
                                    if password_authentication == 0 {
                                            if logged_on_days > 1 || logged_on_minutes >= password_authentication_expiry {
                                                self.resetLogonPage()
                                                return
                                            }
                                        
                                    } else if password_authentication == 3, hour_minute_splited.count == 2 {
                                        let date = Date()
                                        
                                        let calender = Calendar.current
                                        let today_hour = calender.component(.hour, from: date)
                                        let today_minutes = calender.component(.minute, from: date)
                                        
                                        if let hour = Int(hour_minute_splited[0]), let minutes = Int(hour_minute_splited[1]) {
                                            
                                            print(hour)
                                            print(minutes)
                                            print(today_hour)
                                            print(today_minutes)

                                            if (logged_on_days > 1) || (today_hour > hour && logged_on_hours > (today_hour-hour)) || (today_hour == hour && today_minutes >= minutes && logged_on_minutes > (today_minutes-minutes)) {
                                                self.resetLogonPage()
                                                return
                                            }
                                        }
                                    }
                                    } else {
                                        self.resetLogonPage()
                                        return
                                    }
                                }
                                
                                self.canAllowRfidEnroll = is_allow_badge_enrollment
                                let bgColour = NSColor(hex: logonBgColor_hex).cgColor
                                
                                    
                                    if let companyLogoString = companyConfiguration["companyLogo"] as? String, !companyLogoString.isEmpty, let logoUrl = URL(string: companyLogoString) {
                                        do {
                                            let logoData = try Data(contentsOf: logoUrl)
                                            self.companyLogoImage = NSImage(data: logoData)
                                        } catch let err as NSError {
                                            self.companyLogoImage = nil
                                            print(err.localizedDescription)
                                            defer { sem.signal() }
                                        }
                                    } else {
                                        self.companyLogoImage = nil
                                    }
                                    
                                    if !logon_screen_background_url_string.isEmpty, let logon_background_image_url = URL(string: logon_screen_background_url_string) {
                                        do {
                                            let bgImageData = try Data(contentsOf: logon_background_image_url)
                                            let bgImage = NSImage(data: bgImageData)
                                            self.appBgImage = bgImage
                                        } catch let err as NSError {
                                            self.appBgImage = nil
                                            print(err.localizedDescription)
                                            defer { sem.signal() }
                                        }
                                    } else {
                                        self.appBgImage = nil
                                    }
                                
                                DispatchQueue.main.async {
                                    self.instructionMsg.textColor = self.appFontColour
                                    self.infoMsg.textColor = self.appFontColour
                                    self.appLogoBtn.image = self.companyLogoImage
                                    self.helpDeskField.stringValue = helpText
                                    self.displayTextFieldOnLogonScreen.stringValue = disclaimer_string
                                    self.splitView.layer?.backgroundColor = bgColour
                                    self.splitView.layer?.contents = self.appBgImage
                                    self.UserName.isHidden = !does_username_display_on_screen
                                    self.CompanyName.textColor = self.appFontColour
                                    self.UserName.textColor = self.appFontColour
                                    self.authModeImageView.contentTintColor = self.appFontColour
                                    self.rightButton.contentTintColor = self.appFontColour
                                    self.leftButton.contentTintColor = self.appFontColour
                                    self.eyeButton.contentTintColor = self.appFontColour
                                    self.pinCancelButton.contentTintColor = self.appFontColour
                                    self.networkLogonButton.contentTintColor = self.appFontColour
                                    self.powerBtn.isHidden = !does_display_powerbtn_loginscreen
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
    
    func minutes(from date: Date) -> Int {
            return Calendar.current.dateComponents([.minute], from: date, to: Date()).minute ?? 0
    }
    
    func hours(from date: Date) -> Int {
            return Calendar.current.dateComponents([.hour], from: date, to: Date()).hour ?? 0
    }
    
    func days(from date: Date) -> Int {
            return Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
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
                          "MachineName":computerName,
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
                           "SessionId":self.accessToken,
                           "Totp":nil,
                           "FacilityAccessCode":nil,
                           "CardId":nil,
                           "AuthFactor":nil,
                           "SourceApplication":"Windows",
                           "EventType":21,
                           "BioRequest":bioRequest,
                           "UserGeographics":userGeo,
                           "DeviceInfo": deviceData] as [String : AnyObject]
        
        print(url as Any)
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
                            DispatchQueue.main.async {
                                self.hideAllAuthFactors()
                              for factorDic in authFactors   {
                                if let authFactorDic = factorDic as? Dictionary<String, Any>, let factor = authFactorDic["AuthFactor"] as? Int, let factorValue = AuthFactors(rawValue: factor) {
                                        self.closeLeftSidebar()
                                        self.closeRightSideBar()
                                        self.authModeImageView.isHidden = false
                                        self.instructionMsg.isHidden = false
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
    
    
    func hideAllAuthFactors() {
        self.isRFIDenrolled = false
        self.pushButton.isHidden = true
        self.totpButton.isHidden = true
        self.pinButton.isHidden = true
        self.rfidButton.isHidden = true
        self.smsButton.isHidden = true
        self.callButton.isHidden = true
    }
    
    func enableAuthFactosWith(factor:AuthFactors) {
        switch factor {
        case .Face:
            faceButton.isHidden = false
            break
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
                          "signon_application":applicationName] as [String : AnyObject]
        
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
    
    
    @IBAction func submit_network_logon(_ sender: Any) {
        let userNametempdata = txtUsername_networklogon.stringValue + "\0"
        let passwordTempdata = txtPassword_networklogon.stringValue + "\0"
        self.process_login(userName:userNametempdata,passWord:passwordTempdata)
    }
    
    @IBAction func clearFields(_ sender: Any) {
        self.txtUsername_networklogon.stringValue = ""
        self.txtPassword_networklogon.stringValue = ""
       // self.closeRightSideBar()
    }
    
    func submit_pin_authentication(value:String) {
        let success = getAuth(endUrl: "Authenticate", userID: sMainUserID, authID: value)
        if(!success)
        {
            print("authentication failed")
            self.infoMsg.isHidden=false
            self.infoMsg.textColor = appFontColour
            self.infoMsg.stringValue = "PIN authentication failed."
            
        } else {
            self.infoMsg.isHidden=false
            self.infoMsg.textColor = appFontColour
            self.infoMsg.stringValue = "PIN authentication done.Logging you in please wait."
            let userNametempdata = sUsername + "\0"
            let passwordTempdata = sPassword + "\0"
            self.process_login(userName:userNametempdata,passWord:passwordTempdata)
        }
    }
    
    func clearAllPinEntries() {
        self.txtSecurePin1.stringValue = ""
        self.txtSecurePin2.stringValue = ""
        self.txtSecurePin3.stringValue = ""
        self.txtSecurePin4.stringValue = ""
        self.txtSecurePin5.stringValue = ""
        self.txtSecurePin6.stringValue = ""
        
        self.txtPlainPin1.stringValue = ""
        self.txtPlainPin2.stringValue = ""
        self.txtPlainPin3.stringValue = ""
        self.txtPlainPin4.stringValue = ""
        self.txtPlainPin5.stringValue = ""
        self.txtPlainPin6.stringValue = ""
    }
    
    @IBAction func cancel_pin_click(_ sender: Any) {
        self.rfid_click(self)
    }
    
    
    func displayedFaceAuthInstructions(completion: @escaping (Bool)->()) {
        DispatchQueue.main.async {
            self.tabPin.isHidden=true
            self.tabRFID.isHidden=true
            self.infoMsg.stringValue = ""
            self.authModeImageView.image = NSImage(named: "Push_ICO")
            self.instructionMsg.textColor = self.appFontColour
            self.instructionMsg.stringValue = "Started authenticating, please wait."
            completion(true)
        }
    }
    
    
    @IBAction func face_click(_ sender: Any) {
        self.stopTimer()
        self.clearAllPinEntries()
        self.displayedFaceAuthInstructions(completion: { displayed in
            if displayed == true {
                self.faceCaptureView.isHidden = false
                do {
                    try self.cameraManager.startSession()
                } catch {
                  // Cath the error here
                  print(error.localizedDescription)
                }
            }
        })
       
    }
    
    @IBAction func face_retake_click(_ sender: Any) {
        self.faceImageView.isHidden = true
        self.retakeButton.isHidden = true
        self.continueButton.isHidden = true
        do {
            try self.cameraManager.startSession()
        } catch {
          // Cath the error here
          print(error.localizedDescription)
        }
    }
    
    @IBAction func face_continue_click(_ sender: Any) {
        DispatchQueue.main.async {
            self.faceCaptureView.isHidden = true
            self.retakeButton.isHidden = true
            self.continueButton.isHidden = true
            self.faceImageView.isHidden = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            guard let faceImg = self.faceImage else { return }
            self.postFaceRequest(image: faceImg, process_type: 2)
        }
    }
    
    
    @IBAction func face_cancel_click(_ sender: Any) {
        self.faceCaptureView.isHidden = true
        self.retakeButton.isHidden = true
        self.continueButton.isHidden = true
        self.faceImageView.isHidden = true
        do {
          try cameraManager.stopSession()
        } catch {
          // Cath the error here
          print(error.localizedDescription)
        }
        self.rfid_click(sender)
    }
    
    func displayedPushAuthInstructions(completion: @escaping (Bool)->()) {
        DispatchQueue.main.async {
            self.tabPin.isHidden=true
            self.tabRFID.isHidden=true
            self.infoMsg.stringValue = ""
            self.authModeImageView.image = NSImage(named: "Push_ICO")
            self.instructionMsg.textColor = self.appFontColour
            self.instructionMsg.stringValue = "Respond to the push notification on your phone"
            completion(true)
        }
    }
    
    @objc func AuthenticatePush() {
        let success = self.getAuth(endUrl: "Authenticate", userID: self.sMainUserID, authID: "PUSH")
         if(!success)
         {
             print("authentication failed")
             self.infoMsg.isHidden=false
             self.infoMsg.textColor = appFontColour
             self.infoMsg.stringValue = "PUSH authentication failed."
             
         } else {
             self.infoMsg.isHidden=false
             self.infoMsg.textColor = appFontColour
             self.infoMsg.stringValue = "PUSH authentication done.Logging you in please wait."
             let userNametempdata = sUsername + "\0"
             let passwordTempdata = sPassword + "\0"
             self.process_login(userName:userNametempdata,passWord:passwordTempdata)
         }
    }
    
    
    
    @IBAction func push_click(_ sender: Any) {
        self.stopTimer()
        self.clearAllPinEntries()
        self.displayedPushAuthInstructions(completion: { displayed in
            if displayed == true {
                self.perform(#selector(self.AuthenticatePush), with: nil, afterDelay: 0.2)
            }
        })
       
    }
    
    @IBAction func pin_click(_ sender: Any) {
        self.stopTimer()
        self.clearAllPinEntries()
        tabPin.isHidden=false
        isSecurePin = true
        txtSecurePin1.becomeFirstResponder()
        tabRFID.isHidden=true
        self.infoMsg.stringValue = ""
        self.authModeImageView.image = NSImage(named: "PIN_ICO")
        self.instructionMsg.textColor = appFontColour
        self.instructionMsg.stringValue = "Enter PIN"
    }
    
    @IBAction func passcode_click(_ sender: Any) {
        self.stopTimer()
        self.clearAllPinEntries()
        tabPin.isHidden=false
        isSecurePin = true
        txtSecurePin1.becomeFirstResponder()
        tabRFID.isHidden=true
        self.infoMsg.stringValue = ""
        self.authModeImageView.image = NSImage(named: "PIN_ICO")
        self.instructionMsg.textColor = appFontColour
        self.instructionMsg.stringValue = "Enter Passcode"
    }
    
    func displayedPhoneCallingAuthInstructions(completion: @escaping (Bool)->()) {
        DispatchQueue.main.async {
            self.tabPin.isHidden=false
            self.isSecurePin = true
            self.txtSecurePin1.becomeFirstResponder()
            self.tabRFID.isHidden=true
            self.infoMsg.stringValue = ""
            self.authModeImageView.image = NSImage(named: "PIN_ICO")
            self.instructionMsg.textColor = self.appFontColour
            self.instructionMsg.stringValue = "Enter the PIN from your phone call"
            completion(true)
        }
    }
    
    @objc func AuthenticatePhoneCall() {
        let success = self.getAuth(endUrl: "Authenticate", userID: self.sMainUserID, authID: "CALL")
         if(!success)
         {
             print("call failed")
         } else {
             print("call sent")
         }
    }
    
    @IBAction func call_click(_ sender: Any) {
        self.stopTimer()
        self.clearAllPinEntries()
        self.displayedPhoneCallingAuthInstructions { displayed in
            if displayed == true {
                self.perform(#selector(self.AuthenticatePhoneCall), with: nil, afterDelay: 0.2)
            }
        }
    }
    
    func displayedPhoneSMSAuthInstructions(completion: @escaping (Bool)->()) {
        DispatchQueue.main.async {
            self.tabPin.isHidden=false
            self.isSecurePin = true
            self.txtSecurePin1.becomeFirstResponder()
            self.tabRFID.isHidden=true
            self.infoMsg.stringValue = ""
            self.authModeImageView.image = NSImage(named: "PIN_ICO")
            self.instructionMsg.textColor = self.appFontColour
            self.instructionMsg.stringValue = "Enter the PIN from your phone"
            completion(true)
        }
    }
    
    @objc func AuthenticatePhoneSMS() {
        let success = self.getAuth(endUrl: "Authenticate", userID: self.sMainUserID, authID: "SMS")
         if(!success)
         {
             print("sms failed")
         } else {
             print("sms sent")
         }
    }
    
    @IBAction func sms_click(_ sender: Any) {
        self.stopTimer()
        self.clearAllPinEntries()
        self.displayedPhoneSMSAuthInstructions { displayed in
            if displayed == true {
                self.perform(#selector(self.AuthenticatePhoneSMS), with: nil, afterDelay: 0.2)
            }
        }
    }
    
    func grantPermissions() {
        if !IOHIDRequestAccess(kIOHIDRequestTypeListenEvent) {
            //print("Not granted input monitoring")
            self.instructionMsg.textColor = appFontColour
            self.instructionMsg.stringValue = "Not granted input monitoring"
        } else {
            //print("Granted input monitoring")
            self.instructionMsg.textColor = appFontColour
            self.instructionMsg.stringValue = "Granted input monitoring"
            self.startTimer()
        }
    }
    
    @IBAction func rfid_click(_ sender: Any) {
        self.clearAllPinEntries()
        tabPin.isHidden=true
        tabRFID.isHidden=false
        grantPermissions()
        self.infoMsg.stringValue = ""
        self.instructionMsg.textColor = appFontColour
        self.authModeImageView.image = NSImage(named: "RFID_ICO")
    }
    

    func rfid_enrollemnt(success:Bool) {
        DispatchQueue.main.async {
            if(!success)
            {
                self.infoMsg.isHidden=false
                self.infoMsg.textColor = self.appFontColour
                self.infoMsg.stringValue = "RFID enrollment failed."
                
            } else {
                self.infoMsg.isHidden=false
                self.infoMsg.textColor = self.appFontColour
                self.infoMsg.stringValue = "RFID enrollment done"
                self.enableAuthFactosWith(factor: .Rfid)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.rfid_click(self)
            }
        }
    }
    
    func rfid_authentication(success:Bool) {
        DispatchQueue.main.async {
            if(!success)
            {
                print("authentication failed")
                self.infoMsg.isHidden=false
                self.infoMsg.textColor = self.appFontColour
                self.infoMsg.stringValue = "RFID authentication failed."
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.rfid_click(self)
                }
                
            } else {
                self.infoMsg.isHidden=false
                self.infoMsg.textColor = self.appFontColour
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

           nRFID = GetActiveRFID()
          //  print(nRFID as Any)
            if(nRFID==1001)
            {
                self.instructionMsg.textColor = appFontColour
                self.instructionMsg.stringValue = "Reader not connected"
            }
            else if(nRFID==0)
            {
                self.instructionMsg.textColor = appFontColour
                self.instructionMsg.stringValue = "Tap your Card"
            }
            else
            {
                self.stopTimer()
                var rfIdentifier = ""
                var st = String(format:"%02X", nRFID)
                if st.count == 5 {
                    st = "0".appending(st)
                } else if st.count == 7 {
                    st = "0".appending(st)
                }
                print(st)
                if st.count == 6 {
                    
                    let firstTwo = st.suffix(2)
                    let lastTwo = st.prefix(2)
                    let startIdx = st.index(st.startIndex, offsetBy: 2)
                    let endIdx = st.index(st.endIndex, offsetBy: -2)
                    let range = startIdx..<endIdx
                    let middleTwo = st[range]
                    rfIdentifier = firstTwo.appending(middleTwo).appending(lastTwo)
                    print(rfIdentifier)
                    
                } else if st.count == 8 {
                    
                    let firstTwo = st.suffix(2)
                    let lastTwo = st.prefix(2)
                    
                    let start4Idx = st.index(st.startIndex, offsetBy: 4)
                    let end2Idx = st.index(st.endIndex, offsetBy: -2)
                    let midrange1 = start4Idx..<end2Idx
                    
                    let start2Idx = st.index(st.startIndex, offsetBy: 2)
                    let end4Idx = st.index(st.endIndex, offsetBy: -4)
                    let midrange2 = start2Idx..<end4Idx

                    let firstMiddleTwo = st[midrange1]
                    let secondMiddleTwo = st[midrange2]

                    rfIdentifier = firstTwo.appending(firstMiddleTwo).appending(secondMiddleTwo).appending(lastTwo)
                    print(rfIdentifier)
                }
                
                guard rfIdentifier != "" else {
                    self.instructionMsg.stringValue = "It is an unrecognized RFID card"
                    return
                }
                
                self.rfIdentifierStr = rfIdentifier
                self.instructionMsg.textColor = appFontColour
                if self.isRFIDenrolled == false {
                    if self.canAllowRfidEnroll == true {
                        self.rfidEnrollIsInProgress = true
                        self.resetLogonPage()
                    } else {
                        self.instructionMsg.stringValue = "Policy denied. RFID enrollment is not permitted"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.rfid_click(self)
                        }
                    }
                } else {
                    self.instructionMsg.stringValue = "Started authenticating, please wait."
                    _ = self.getAuth(endUrl: "AuthenticateRFID", userID: self.sMainUserID, authID: rfIdentifier)
                }
                
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
            self.infoMsg.textColor = appFontColour
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
                NSApplication.shared.terminate(self)
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


extension AuthxSignIn: CameraManagerDelegate {
    
    func convert(cmage: CIImage) -> CGImage {
         let context = CIContext(options: nil)
         let cgImage = context.createCGImage(cmage, from: cmage.extent)!
         return cgImage
    }
    
    
  func cameraManager(_ output: CameraCaptureOutput, didOutput sampleBuffer: CameraSampleBuffer, from connection: CameraCaptureConnection) {
       print(Date())
      let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
      let ciimage = CIImage(cvPixelBuffer: imageBuffer)
      let image = self.convert(cmage: ciimage)
 
      let request = VNDetectFaceRectanglesRequest()
      let handler = VNImageRequestHandler(cgImage: image, orientation: .upMirrored, options: [:])
         
         DispatchQueue.global().async {
             try? handler.perform([request])
             
             guard let observations = request.results, observations.count > 0 else {
                 return
             }
             let observation = observations[0]
             
             DispatchQueue.main.async {
             if observation.confidence > 0.9 {
                 do {
                     try self.cameraManager.stopSession()
                 } catch {
                   // Cath the error here
                   print(error.localizedDescription)
                 }
                 let myNsImage = NSImage(cgImage: image, size: .zero)
                     
//                     self.retakeButton.isHidden = false
//                     self.continueButton.isHidden = false
                     self.faceImageView.image = myNsImage
                     self.faceImageView.isHidden = false
                 
                     self.faceImage = myNsImage
                     DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                         self.faceCaptureView.isHidden = true
                         guard let faceImg = self.faceImage else { return }
                         self.postFaceRequest(image: faceImg, process_type: 2)
                     }
                 }
                 
             }
            
         }
  }
    
    
    func postFaceRequest(image:NSImage, process_type:Int) {
        
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String  else {
            return
        }
        
        let deviceData = ["browser_name":"",
                          "browser_version":"",
                          "os":"Microsoft Windows 10 Pro",
                          "os_version":"10.0.19045",
                          "app_version":appVersion,
                          "device_name":self.computerName,
                          "local_domain":"CERTIFY",
                          "ad_domain":"CERTIFY",
                          "src_user_id":self.sUserID ?? "",
                          "loggedon_user":self.sUsername ?? "",
                          "signon_application":applicationName,
                          "oftr":false] as [String : AnyObject]
        
        
        let applicationParameters = ["application_key":self.sAppID,"secret_key":self.sAppKey,"host_name":self.sAppHost,"biometric_session_id":self.accessToken] as [String : AnyObject]

        let userParameters =  ["user_name":self.sMainUserID ?? "",
                           "process_type":process_type,
                           "authentication_id":2,
                           "correlation_id":self.guid,
                           "unique_id":self.sMainUserID ?? "",
                           "applicationType":"Windows",
                           "Apptype":applicationName,
                           "application_parameters":applicationParameters,
                           "device_data":deviceData] as [String : AnyObject]
        
            
            guard let mediaImage = Media(withImage: image, forKey: "biometricdata") else { return }
            
            let APIUrl = sAppAPI + "ProcessBiometric"

            guard let url = URL(string: APIUrl) else { return }
        
        
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let boundary = generateBoundary()
            
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
            request.setValue(self.sAppID, forHTTPHeaderField: "ApplicationId")
            request.setValue(self.sAppKey, forHTTPHeaderField: "ApplicationKey")
            request.setValue(self.sAppHost, forHTTPHeaderField: "CompanyHostName")
            request.setValue(self.guid, forHTTPHeaderField: "PcIdentifier")
            request.setValue(self.guid, forHTTPHeaderField: "TraceId")
                    
            let dataBody = createDataBody(withParameters: userParameters, media: [mediaImage], boundary: boundary)
        
            let sem = DispatchSemaphore.init(value: 0)

            URLSession.shared.uploadTask(with: request, from: dataBody, completionHandler: { responseData, response, error in
                if error == nil {
                    let jsonData = try? JSONSerialization.jsonObject(with: responseData!, options: .allowFragments)
                    if let json = jsonData as? [String: Any] {
                        if let response_code = json["response_code"] as? Int, response_code == 1 {
                            DispatchQueue.main.async {
                                self.infoMsg.stringValue = "Face authentication done.Logging you in please wait."
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    let userNametempdata = self.sUsername + "\0"
                                    let passwordTempdata = self.sPassword + "\0"
                                    self.process_login(userName:userNametempdata,passWord:passwordTempdata)
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.infoMsg.stringValue = "Face authentication failed."
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.rfid_click(self)
                            }
                        }
                        do { sem.signal() }
                    }
                } else {
                    do { sem.signal() }
                }
            }).resume()
        
            
//            let session = URLSession.shared
//            session.dataTask(with: request) { (data, response, error) in
//                if let response = response {
//                    print(response)
//                }
//                
//                if let data = data {
//                    do {
//                        let json = try JSONSerialization.jsonObject(with: data, options: [])
//                        print(json)
//                    } catch {
//                        print(error)
//                    }
//                }
//                }.resume()
        }
        
    func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
        
    func createDataBody(withParameters params: [String:AnyObject]?, media: [Media]?, boundary: String) -> Data {
        
        let lineBreak = "\r\n"
        var body = Data()
        
//        if let parameters = params {
//            for (key, value) in parameters {
//                if let val = value as? Dictionary<String,Any> {
//                    for (key2, value2) in val {
//                        if let val2 = value2 as? Dictionary<String,Any> {
//                            for (key3, value3) in val2 {
//                               // if let val3 = value3 as? String {
//                                    body.append("--\(boundary + lineBreak)")
//                                    body.append("Content-Disposition: form-data; name=\"\(key3)\"\(lineBreak + lineBreak)")
//                                    body.append("\(value3)\(lineBreak)")
//                                    print("\(key3)\(value3)")
//                              //  }
//                            }
//                        } else {
//                           // if let val2 = value2 as? String {
//                                body.append("--\(boundary + lineBreak)")
//                                body.append("Content-Disposition: form-data; name=\"\(key2)\"\(lineBreak + lineBreak)")
//                                body.append("\(value2)\(lineBreak)")
//                                print("\(key2)\(value2)")
//                           // }
//                        }
//                    }
//                } else {
//                    //if let val = value as? String {
//                        body.append("--\(boundary + lineBreak)")
//                        body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
//                        body.append("\(value)\(lineBreak)")
//                        print("\(key)\(value)")
//                   // }
//                }
//            }
//          }
//        
        guard let parameters = params else {
            return body
        }

        let jsonData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        print(decoded)
        let key = "processBiometrics"
       // if let parameters = params {
           // for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(decoded)\(lineBreak)")
                print("\(key)\(decoded)")
//            }
//        }
            
            if let media = media {
                for photo in media {
                    body.append("--\(boundary + lineBreak)")
                    body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
                    body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                    body.append(photo.data)
                    body.append(lineBreak)
                }
            }
            
            body.append("--\(boundary)--\(lineBreak)")
            return body
        }
    
}



extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}


struct Media {
    let key: String
    let filename: String
    let data: Data
    let mimeType: String
    
    init?(withImage image: NSImage, forKey key: String) {
        self.key = key
        self.mimeType = "image/jpeg"
        self.filename = "biometricData.jpg"
        guard let data = image.compressUnderMegaBytes(megabytes: 0.2) else { return nil }
        print(data.count)
        self.data = data
    }
    
}

extension NSImage {
    func compressUnderMegaBytes(megabytes: CGFloat) -> Data? {

        var compressionRatio = 1.0
        guard let tiff = self.tiffRepresentation, let imageRep = NSBitmapImageRep(data: tiff) else { return nil }
        var compressedData = imageRep.representation(using: .jpeg, properties: [.compressionFactor : compressionRatio])!
        while CGFloat(compressedData.count) > megabytes * 1024 * 1024 {
            compressionRatio = compressionRatio * 0.9
            compressedData = imageRep.representation(using: .png, properties:  [.compressionFactor : compressionRatio])!
            if compressionRatio <= 0.4 {
                break
            }
        }
        return compressedData
    }
}



