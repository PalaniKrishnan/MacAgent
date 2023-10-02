/*
 * Copyright (c) 2022 Idemeum
 * All Rights Reserved.
 */

import Cocoa

class Constant: NSObject {
    
    static let desktopAppType:String = "DESKTOP_LOGIN"
    static let mfaSecretLength:Int = 10
    static let TOTPDigits:Int = 6
    static let TOTPSeconds:Int = 30
    static let TOTPAlgorithm:String = "sha-1"
    
    #if IDEMEUMSTAGING
    static let domainRegex = "^.+\\.idemeumlab\\.com$"
    #else
    static let domainRegex = "^.+\\.idemeum\\.com$"
    #endif
    
    //MARK: UserDefaults Key
    struct UserDefaultsKey {
        static let tenantName = "TenantName"
    }
    
    struct Key {
        static let csrfToken = "csrfToken"
        static let loginCtxId = "loginCtxId"
        static let signinId = "signinId"
        static let qrCodeBase64 = "qrCodeBase64"
        static let tenant = "tenant"
        static let status = "status"
        static let idemeumToken = "IdemeumToken"
        static let DVMI_ID = "DVMI_ID"
        static let hdnXIdemeumCSRFToken = "hdnXIdemeumCSRFToken"
        static let idemeum_CSRF = "Idemeum-CSRF"
        static let userPasswordPublicKey = "userPasswordPublicKey"
        static let appId = "appId"
        static let details = "details"
    }
    
    //MARK: URLs
    struct URL {
        static let privacy = "https://idemeum.com/2021/09/05/idemeum-keeps-identity-secure-and-private/#"
        static let idemeum = "https://idemeum.com/"
    }
    
    // MARK: - Alert Constants
    enum AlertButtonTitle {
        static let Ok = "Ok"
        static let Cancel = "Cancel"
        static let Yes = "Yes"
        static let No = "No"
        static let NotNow = "Not Now"
        static let DontShowAgain = "Don't Show Again"
        static let CaptureMore = "Capture More"
        static let NotRightNow = "Not Right Now"
        static let Update = "Update"
        static let Settings = "Settings"
    }
    
    //Alert titles
    struct AlertTitle {
        static let alert = "Alert!"
        static let success = "Success"
        static let Idemeum = "idemeum"
        static let AuthenticationFailed = "Authentication Failed!"
        static let noInternet = "No Internet."
    }
    
    
    //MARK: Messages
    struct Message {
        static let noInternetMsg = "Internet connection is not available, Please, check the connection and retry."
        static let generalMsg = "Whoops! Something went wrong, Please try after some time."
        static let emptyTenantURL = "Please enter tenant URL"
        static let invalidURL = "Please enter valid URL."
        static let failedToGetComputerName = "Unable to get you machine name"
        static let unableToGetSigninData = "Unable to get signin data, Please try again."
        static let invalidTenantURL = "Invalid tenant URL, Please enter valid idemeum tenant URL"
        static let qrCodeIssue = "Unable to show QR code for login."
        static let signinPollingFailed = "Sign-in could not complete"
        
        static let aboutText:String = """
    Welcome to idemeum!
    
    At idemeum we are on a mission to make digital identity simple, secure, and private.
    
    With idemeum you can eliminate passwords, securely login to you personal and corporate accounts, and protect your digital identity from fraud.
    
    Learn more at idemeum.com
    """
    }
    
}

enum SigninPollingStatus:String {
    case IN_PROGRESS
    case COMPLETED
    case FAILED
    case TIMEOUT
    case GROUP_RECOVERY_APPROVAL_REQUIRED
    case GROUP_RECOVERY_APPROVED
    case GROUP_RECOVERY_CONFIGURATION_MISSING
}
