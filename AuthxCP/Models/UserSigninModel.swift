/*
 * Copyright (c) 2022 Idemeum
 * All Rights Reserved.
 */

import Cocoa

class UserSigninModel: NSObject {

    static var shared = UserSigninModel()
    
    var signinId: String = ""
    var tenantName: String = ""
    var qrCodeBase64: String = ""

    func signinData(id:String, name:String, qrCode:String) {
        self.signinId = id
        self.tenantName = name
        self.qrCodeBase64 = qrCode
    }
}

class SigninPolling: NSObject {
    static var shared = SigninPolling()
    
    var DVMI_ID:String = ""
    var idemeumToken:String = ""
    
    func getCookie() -> String {
        return "\(Constant.Key.DVMI_ID)=\(self.DVMI_ID);\(Constant.Key.idemeumToken)=\(self.idemeumToken)"
    }
}

class Userportal:NSObject {
    static var shared = Userportal()
    
    var hdnXIdemeumCSRFToken:String = ""
    var idemeum_CSRF:String = ""
    
    func getCookie() -> String {
        return "\(SigninPolling.shared.getCookie());\(Constant.Key.idemeum_CSRF)=\(self.idemeum_CSRF)"
    }
}
