
import Cocoa
import Security.AuthorizationPlugin
import os
import OpenDirectory
import Foundation
import SwiftUI
import os
import SecurityInterface

class IdemeumSignIn: NSWindowController {
    var backgroundWindow: NSWindow!
    @IBOutlet weak var QRCodeImagebutton: NSButton!
    
    //MARK: - Variables
    var pollingTimer: Timer?
    var pollingTime:TimeInterval = 5.0
    
    var mechCallbacks: AuthorizationCallbacks?
    var mechEngine: AuthorizationEngineRef?
    var bIsFirstAuth:Bool=false
    var usertype:String="local"
    var domain:String=""
    
    @IBOutlet weak var infoMsg: NSTextField!
    @IBOutlet weak var username: NSTextField!
    @IBOutlet weak var password: NSSecureTextField!
    @IBOutlet weak var signIn: NSButton!
    @IBOutlet weak var otherUser: NSButton!
    @IBOutlet weak var passwordLessUser: NSButton!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var otherUserLabel: NSTextField!
    @IBOutlet weak var passwordlessUserLabel: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.level = .screenSaver
                
                self.window?.canBecomeVisibleWithoutLogin=true

                //self.window?.level = .popUpMenu
                self.window?.orderFrontRegardless()

                self.window?.titlebarAppearsTransparent = true

                self.window?.isMovable = false
        bIsFirstAuth=true
        progressIndicator.isHidden=true
        //createBackgroundWindow()
        write_log(value: "createBackgroundWindow called\n")
        UserSigninModel.shared = UserSigninModel()
        write_log(value: "UserSigninModel called\n")
        self.internalLogin_WS()
        
    }
    
    @objc func activeTiming() {
        print("timer block executed")
    }
    
    fileprivate func createBackgroundWindow() {
        //var image: NSImage?
               
        for screen in NSScreen.screens {
            let view = NSView()
            view.wantsLayer = true
            //view.layer!.contents = image
            
            backgroundWindow = NSWindow(contentRect: screen.frame,
                                        styleMask: .fullSizeContentView,
                                        backing: .buffered,
                                        defer: true)
            
            backgroundWindow.backgroundColor =  .blue
            backgroundWindow.contentView = view
            backgroundWindow.makeKeyAndOrderFront(self)
            backgroundWindow.canBecomeVisibleWithoutLogin = true
        }
        
    }
    
    func showHideControls(bPasswordLessUser:Bool){
        username.isHidden = Bool(bPasswordLessUser)
        password.isHidden = Bool(bPasswordLessUser)
        signIn.isHidden = Bool(bPasswordLessUser)
        passwordLessUser.isHidden = Bool(bPasswordLessUser)
        otherUserLabel.isHidden = Bool(bPasswordLessUser)
               
        otherUser.isHidden = Bool(!bPasswordLessUser)
        passwordlessUserLabel.isHidden = Bool(!bPasswordLessUser)
                
    }
    
    @IBAction func otherUserClick(_ sender: Any) {
        showHideControls(bPasswordLessUser: false)
    }
    
    @IBAction func passwordlessUserClick(_ sender: Any) {
        showHideControls(bPasswordLessUser: true)
    }
    
    func process_login(userName:String,passWord:String ) {
        
        self.infoMsg.isHidden=false
        self.infoMsg.stringValue = ""
        let success = authenticateLocalUser(username: userName, password: passWord)
        if(!success)
        {
            self.infoMsg.isHidden=false
            self.infoMsg.stringValue = "The username/password you entered is invalid."
            //self.showNSAlert(message: "The password you entered is invalid. Please check password and try again.")
        }
        else
        {
            self.passwordlessUserLabel.stringValue="Logging in, please wait..."
            progressIndicator.isHidden=false
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
                //self.window?.close()
                //self.backgroundWindow.close()
                //NSApp.stopModal()
            }
        }
    }
    
    @IBAction func signInClick(_ sender: Any) {
            let userNametempdata = username.stringValue + "\0"
            let passwordTempdata = password.stringValue + "\0"
            process_login(userName:userNametempdata,passWord:passwordTempdata)
            bIsFirstAuth=false
    }
    
    @IBAction func closeClick(_ sender: Any) {
        self.window?.close()
        
        //self.backgroundWindow.close()
    }
}

extension IdemeumSignIn {
    
    //MARK: - setup screen UI
    private func setupUI(){
        let splittedData = UserSigninModel.shared.qrCodeBase64.split(separator: ",")
        if splittedData.count > 1 {
            var qrCodeString = String(splittedData[1])
            
            //==== Patch work when get base 64 string not convertable.
            let remaingChar = qrCodeString.count % 4
            for _ in 0..<remaingChar {
                qrCodeString.append("=")
            }
            //====
            
            if let imageData = Data(base64Encoded: qrCodeString) {
                self.imageView.image = NSImage(data: imageData)
                write_log(value: "imageView.image called\n")                
                self.startSigninPolling()
            }else{
                self.showAlertAndGoback(message: Constant.Message.qrCodeIssue)
            }
        }
//        let QRCodeimage = generateQRCode(from: UserSigninModel.shared.qrCodeBase64)
//        QRCodeImagebutton.image = QRCodeimage
    }
    
    private func generateQRCode(from string: String) -> NSImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                let rep = NSCIImageRep(ciImage: output)
                let nsImage = NSImage(size: rep.size)
                nsImage.addRepresentation(rep)
                return nsImage
            }
        }

        return nil
    }
    
    private func startSigninPolling(){
        
            self.pollingTimer?.invalidate()
            self.pollingTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.signinPolling_WS), userInfo: nil, repeats: true)
        
    }
    
    private func showAlertAndGoback(message:String){
        CommonFunctions.hideProgressIndicator()
        CommonFunctions.showNSAlert(title: Constant.AlertTitle.Idemeum, message: message, button: Constant.AlertButtonTitle.Ok) {
            //self.backButtonTapped(CustomButton())
        }
    }
    
    func gotoNextScreen(){
        self.performSegue(withIdentifier: "installationCompleteSegue", sender: nil)
    }
    
    func write_log(value:String) {

        let filePath = "/Users/Shared/log.txt"
        
        let fileUrl = URL(string: filePath)

        let monkeyLine = value

        if let fileUpdater = try? FileHandle(forUpdating: fileUrl!) {

            // Function which when called will cause all updates to start from end of the file
            fileUpdater.seekToEndOfFile()

            // Which lets the caller move editing to any position within the file by supplying an offset
            fileUpdater.write(monkeyLine.data(using: .utf8)!)

            // Once we convert our new content to data and write it, we close the file and that’s it!
            fileUpdater.closeFile()
        }
        
    }
}

//MARK: API calls
extension IdemeumSignIn {
    
    func internalLogin_WS() {
        write_log(value: "internalLogin_WS called\n")
        TenantModel.shared.urlString="https://dev.idemeumlab.com"
        WebServiceManager.shared.internalLogin(successCallback: { (successDict) in
            //CommonFunctions.hideProgressIndicator()
            if let csrfTokenValue = successDict[Constant.Key.csrfToken] as? String,
               let loginCtxIdValue = successDict[Constant.Key.loginCtxId] as? String {
                TenantModel.shared.csrfToken = csrfTokenValue
                TenantModel.shared.loginCtxId = loginCtxIdValue
                self.setupUI()
                self.signInChallenge_WS()
                                              
            }else{
                //self.showNSAlert(message: Constant.Message.generalMsg)
            }
        }) { (failureDict) in
            //CommonFunctions.hideProgressIndicator()
            let errorDescription = failureDict["error_description"] as? String ?? ""
            //self.showNSAlert(message: errorDescription)
        }
    }
    
    func signInChallenge_WS(){
        
        guard let computerName = Host.current().localizedName else {
            self.showAlertAndGoback(message: Constant.Message.failedToGetComputerName)
            return
        }
        
        let signInChallengeRequest:[String : Any] = ["loginCtxId": TenantModel.shared.loginCtxId,
                                                     "appName": computerName,
                                                     "appType": Constant.desktopAppType,
                                                     "forceQrCode": true]
        
        //CommonFunctions.showProgressIndicator(self.view)
        WebServiceManager.shared.signInChallenge(parameters: signInChallengeRequest, successCallback: { (successDict) in
            CommonFunctions.hideProgressIndicator()
            if let signinId = successDict[Constant.Key.signinId] as? String,
               let qrCodeBase64 = successDict[Constant.Key.qrCodeBase64] as? String {
                
                let tenantName = successDict[Constant.Key.tenant] as? String ?? ""
                UserSigninModel.shared.signinData(id: signinId, name: tenantName, qrCode: qrCodeBase64)
                self.setupUI()
            }else{
                self.showAlertAndGoback(message: Constant.Message.unableToGetSigninData)
            }
        }) { (failureDict) in
            self.showAlertAndGoback(message: failureDict["error_description"] as? String ?? Constant.Message.generalMsg)
        }
    }
    
    @objc func signinPolling_WS() {
        write_log(value: "signinPolling_WS called\n")
        WebServiceManager.shared.signinPolling(successCallback: { (successDict) in
            if let status = successDict[Constant.Key.status] as? String {
                if status == SigninPollingStatus.IN_PROGRESS.rawValue {
                    return
                }else if status == SigninPollingStatus.COMPLETED.rawValue {
                    //Next API call.
                    SigninPolling.shared.idemeumToken = successDict[Constant.Key.idemeumToken] as! String
                    SigninPolling.shared.DVMI_ID = successDict[Constant.Key.DVMI_ID] as! String
                    self.redirectUserPortal_WS()
                }else if status == SigninPollingStatus.FAILED.rawValue {
                    self.showAlertAndGoback(message: Constant.Message.signinPollingFailed)
                }
            }else{
                self.showAlertAndGoback(message: Constant.Message.generalMsg)
            }
            self.pollingTimer?.invalidate()
        }) { (failureDict) in
            self.pollingTimer?.invalidate()
            let errorDescription = failureDict["error_description"] as? String ?? Constant.Message.signinPollingFailed
            self.showAlertAndGoback(message: errorDescription)
        }
    }
    
    func redirectUserPortal_WS(){
        write_log(value: "redirectUserPortal_WS called\n")
        //CommonFunctions.showProgressIndicator(self.window.view)
        WebServiceManager.shared.userportal(successCallback: { (successDict) in
            
            if let hdnXIdemeumCSRFToken = successDict[Constant.Key.hdnXIdemeumCSRFToken] as? String,
            let idemeum_CSRF = successDict[Constant.Key.idemeum_CSRF] as? String {
                Userportal.shared.hdnXIdemeumCSRFToken = hdnXIdemeumCSRFToken
                Userportal.shared.idemeum_CSRF = idemeum_CSRF
                //NEXT API call.
                self.fetchClaims_WS()
            }else{
                self.showAlertAndGoback(message: Constant.Message.generalMsg)
            }
        }) { (failureDict) in
            let errorDescription = failureDict["error_description"] as? String ?? ""
            self.showAlertAndGoback(message: errorDescription)
        }
    }
        
    func updateSecret_WS(appID:String, encryptedSharedSecret:String){
        
        let createDesktopAppRequest:[String : Any] = ["encryptedDesktopSharedSecret":encryptedSharedSecret]
        
        WebServiceManager.shared.updateSharedSecretForTOTP(appID: appID, parameters: createDesktopAppRequest, successCallback: { (successDict) in
            self.fetchClaims_WS()
        }) { (failureDict) in
            self.showAlertAndGoback(message: failureDict["error_description"] as? String ?? Constant.Message.generalMsg)
        }
    }
    func read_idemeum_security_map(nFieldID:Int) -> String{
        
        var UpdatedContent:String=""
        
        let fileURL = NSURL(string: "file:///Users/Shared/idemeum_security.ini")
        var retString = "";
        //writing
        do {
            let fileContent = try String(contentsOf: fileURL! as URL, encoding: .utf8)
            
            fileContent.enumerateLines { line, _ in
                UpdatedContent.append(line)
            }
            let row = UpdatedContent.components(separatedBy: ";")
            let cols = row[0].components(separatedBy: ",")
            retString = cols[nFieldID];
        }
            
        catch {/* error handling here */}
        
        return retString;
        //return true;
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
    func fetchClaims_WS(){
        self.write_log(value: "fetchClaims_WS called\n")
        WebServiceManager.shared.getUserInfo(successCallback: { [self] (successDict) in
            let decoder = JSONDecoder()
            if let jsonData = try? JSONSerialization.data(withJSONObject: successDict, options: .prettyPrinted),
               let userInfo = try? decoder.decode(UserInfo.self, from: jsonData){
                UserModel.shared.user = userInfo
                CommonFunctions.hideProgressIndicator()
                
                //Save data to user default
                //tenant name used in installed screen when app open next time.
                CommonFunctions.saveDataToUserDefaults(UserSigninModel.shared.tenantName, forKey: Constant.UserDefaultsKey.tenantName)
                self.write_log(value: "logged in called\n")
                
                let userNametempdata = self.read_idemeum_security_map(nFieldID: 0) + "\0"
                let passwordTempdata = self.read_idemeum_security_map(nFieldID: 2) + "\0"
                self.process_login(userName:userNametempdata,passWord:passwordTempdata)
                //self.gotoNextScreen()
            }else{
                self.showAlertAndGoback(message: Constant.Message.generalMsg)
            }
        }) { (failureDict) in
            self.showAlertAndGoback(message: failureDict["error_description"] as? String ?? Constant.Message.generalMsg)
        }
    }
}
