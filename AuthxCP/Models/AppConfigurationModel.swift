/*
 * Copyright (c) 2022 Idemeum
 * All Rights Reserved.
 */

import Cocoa

struct TOTPConfig {
    var digits:Int = Constant.TOTPDigits
    var encryptedSharedSecret:String = ""
    var hashAlgorithm:String = Constant.TOTPAlgorithm
    var periodInSeconds:Int = Constant.TOTPSeconds
    
    init() {}
    
    init(configInfo:[String:Any]){
        self.digits = configInfo["digits"] as? Int ?? Constant.TOTPDigits
        self.encryptedSharedSecret = configInfo["encryptedSharedSecret"] as? String ?? ""
        self.hashAlgorithm = configInfo["hashAlgorithm"] as? String ?? ""
        self.periodInSeconds = configInfo["periodInSeconds"] as? Int ?? Constant.TOTPSeconds
    }
}

class AppConfigurationModel: NSObject {

    static let shared = AppConfigurationModel()
    
    var catalogId:String = ""
    var appId:String = ""
    var name:String = ""
    var iconUrl:String = ""
    var appType:String = ""
    var totpConfig:TOTPConfig = TOTPConfig()
    var encryptedSecureKey:String = ""
    
    func setAppConfiguration(appInfo:[String:Any]){
        
        self.catalogId = appInfo["catalogId"] as? String ?? ""
        self.appId = appInfo["appId"] as? String ?? ""
        self.name = appInfo["name"] as? String ?? ""
        self.iconUrl = appInfo["iconUrl"] as? String ?? ""
        self.appType = appInfo["appType"] as? String ?? Constant.desktopAppType
        self.encryptedSecureKey = appInfo["encryptedSecureKey"] as? String ?? ""
        
        if let appConfiguration = appInfo["desktopLoginAppConfiguration"] as? [String:Any],
            let totpConfig = appConfiguration["totpConfig"] as? [String:Any] {
            self.totpConfig = TOTPConfig(configInfo: totpConfig)
        }
        
        //Save data to local preferences.
    }
    
}
