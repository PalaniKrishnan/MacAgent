/*
 * Copyright (c) 2022 Idemeum
 * All Rights Reserved.
 */

import Foundation

import Alamofire
class WebServiceManager: NSObject {
    
    static let shared = WebServiceManager()
    var vouchedPrivateKey = ""
    var vouchedPublicKey = ""

    // MARK:- Type Alias
    typealias successClosure = (Dictionary<String, Any>) -> Void
    typealias failureClosure = (Dictionary<String, Any>) -> Void
    
    //MARK:- Headers
    private func preAuthCommonHeader() -> HTTPHeaders {
        return ["Content-Type":"application/json"]
    }
    
    // MARK:- Error Handling
    private func errorHandling(response: [String:Any]) -> [String:Any] {
        var errorDict: [String:Any]
        
        if let errorCode = response["error"] as? Int {
            let message = response["message"] as? String ?? response["error_description"] as? String
            errorDict = [
                "error":errorCode ,
                "error_description":message ?? "Unknown error. Please try again."
                ] as [String:Any]
        }else if (response["errorCode"] as? String) != "" {
            
                let message = response["message"] as? String ?? response["error_description"] as? String
                errorDict = [
                    "error":response["errorCode"] as? String ?? "404",
                    "error_description":message ?? "Unknown error. Please try again."
                    ] as [String:Any]
        } else {
            errorDict = [
                "error":"Unknown",
                "error_description":"Unknown error. Please try again."
                ] as [String:Any]
        }
        
        return errorDict
    }
    
    //MARK: - Web Service Calls
    
    //-------------------------------------------------//
    ////////////////// User Services ////////////////////
    //-------------------------------------------------//
    
    //MARK: - User Services
    
    //Internal login API
    func internalLogin(successCallback: successClosure?, failureCallback: failureClosure?) {

        let internalLoginURL = TenantModel.shared.urlString + "/api/internal/login"
        
        WebServiceBuilder.shared.getCall(serviceURL: internalLoginURL, parameters: nil, headers: self.preAuthCommonHeader(), spinnerState: false, successCallback: { (successDict) in
            print("============ internal Login Response")
            print(successDict)
            successCallback!(successDict)
        }) { (failureDict) in
            print(failureDict)
            failureCallback!(self.errorHandling(response: failureDict))
        }
    }
    
    //Signup Challenge API
    func signInChallenge(parameters:[String:Any], successCallback: successClosure?, failureCallback: failureClosure?) {
        
        let headerParameters:HTTPHeaders = ["Content-Type": "application/vnd.dvmi.signin.challenge.request+json",
                                            "accept": "application/vnd.dvmi.signin.challenge.response+json",
                                            "x-idemeum-csrf-token-login":TenantModel.shared.csrfToken]
        
        let challengeUrl = TenantModel.shared.urlString + "/api/signin/v2/challenge"
        
        print("============ SignIn Challenge Request ============")
        print("signIn Challenge URL :: ",challengeUrl)
        print(parameters)
        
        WebServiceBuilder.shared.postCall(serviceURL: challengeUrl, parameters: parameters, headers: headerParameters, spinnerState: false, successCallback: { (successDict) in
            print("============ SignIn Challenge Response ============")
            print(successDict)
            successCallback!(successDict)
        }) { (failureDict) in
            print(failureDict)
            failureCallback!(self.errorHandling(response: failureDict))
        }
    }
    
    //Signin Polling API
    func signinPolling(successCallback: successClosure?, failureCallback: failureClosure?){
        
        let headerParameters:HTTPHeaders = ["x-idemeum-csrf-token-login":TenantModel.shared.csrfToken]
        
        let signinPollingURL = TenantModel.shared.urlString + "/api/signin/v2/polling?signinId=" + UserSigninModel.shared.signinId
        
        WebServiceBuilder.shared.getCall(serviceURL: signinPollingURL, parameters: nil, headers: headerParameters, spinnerState: false, successCallback: { (successDict) in
            print("============ Signin Polling Response")
            print(successDict)
            successCallback!(successDict)
        }) { (failureDict) in
            print(failureDict)
            failureCallback!(self.errorHandling(response: failureDict))
        }
    }
    
    //Portal redirection
    func userportal(successCallback: successClosure?, failureCallback: failureClosure?){
        
        let headerParameters:HTTPHeaders = ["Cookie":SigninPolling.shared.getCookie()]
        
        let userPortalURL = TenantModel.shared.urlString + "/userportal"
        
        WebServiceBuilder.shared.getCall(serviceURL: userPortalURL, parameters: nil, headers: headerParameters, spinnerState: false, successCallback: { (successDict) in
            print("============ User Portal Response")
            print(successDict)
            successCallback!(successDict)
        }) { (failureDict) in
            print(failureDict)
            failureCallback!(self.errorHandling(response: failureDict))
        }
    }
    
    //Get user public key.
    func getPublicKey(successCallback: successClosure?, failureCallback: failureClosure?){
        
        let headerParameters:HTTPHeaders = ["X-Idemeum-CSRF-Token":Userportal.shared.hdnXIdemeumCSRFToken,
                                            "accept":"application/vnd.dvmi.my.public.key+json",
                                            "Cookie":Userportal.shared.getCookie()]
        
        let getPublicKeyURL = TenantModel.shared.urlString + "/api/users/publickeys/me"
        
        WebServiceBuilder.shared.getCall(serviceURL: getPublicKeyURL, parameters: nil, headers: headerParameters, spinnerState: false, successCallback: { (successDict) in
            print("============ Get PublicKey Response")
            print(successDict)
            successCallback!(successDict)
        }) { (failureDict) in
            print(failureDict)
            failureCallback!(self.errorHandling(response: failureDict))
        }
    }
    
    //Create Desktop login app
    func desktoploginApp(parameters:[String:Any], successCallback: successClosure?, failureCallback: failureClosure?) {
        
        let headerParameters:HTTPHeaders = ["Content-Type": "application/vnd.dvmi.desktop.login.application.with.config+json",
                                            "accept": "application/vnd.dvmi.desktop.login.application+json",
                                            "X-Idemeum-CSRF-Token":Userportal.shared.hdnXIdemeumCSRFToken,
                                            "Cookie":Userportal.shared.getCookie()]
        
        let desktoploginUrl = TenantModel.shared.urlString + "/api/desktoplogin/apps"
        
        print("============ Desktoplogin App Request ============")
        print(headerParameters)
        print("desktoplogin URL :: ",desktoploginUrl)
        print(parameters)
        
        WebServiceBuilder.shared.postCall(serviceURL: desktoploginUrl, parameters: parameters, headers: headerParameters, spinnerState: false, successCallback: { (successDict) in
            print("============ Desktoplogin App Response ============")
            print(successDict)
            successCallback!(successDict)
        }) { (failureDict) in
            print(failureDict)
            failureCallback!(self.errorHandling(response: failureDict))
        }
    }
    
    //update shared secret for TOTP
    func updateSharedSecretForTOTP(appID:String, parameters:[String:Any], successCallback: successClosure?, failureCallback: failureClosure?) {
        
        let headerParameters:HTTPHeaders = ["Content-Type": "application/vnd.dvmi.desktop.login.app.totp.config+json",
                                            //"accept": "application/vnd.dvmi.desktop.login.application+json",
                                            "X-Idemeum-CSRF-Token":Userportal.shared.hdnXIdemeumCSRFToken,
                                            "Cookie":Userportal.shared.getCookie()]
        
        let updateSecretUrl = TenantModel.shared.urlString + "/api/desktoplogin/apps/" + appID
        
        print("============ Update secret Request ============")
        print(headerParameters)
        print("Update secret URL :: ",updateSecretUrl)
        print(parameters)
        
        WebServiceBuilder.shared.patchCall(serviceURL: updateSecretUrl, parameters: parameters, headers: headerParameters, spinnerState: false, successCallback: { (successDict) in
            print("============ Update secret Response ============")
            print(successDict)
            successCallback!(successDict)
        }) { (failureDict) in
            print(failureDict)
            failureCallback!(self.errorHandling(response: failureDict))
        }
    }
    
    //To fetch claims
    func getUserInfo(successCallback: successClosure?, failureCallback: failureClosure?){
        
        let headerParameters:HTTPHeaders = ["X-Idemeum-CSRF-Token":Userportal.shared.hdnXIdemeumCSRFToken,
                                            "accept":"application/vnd.dvmi.user.info+json",
                                            "Cookie":Userportal.shared.getCookie()]
        
        let userInfoURL = TenantModel.shared.urlString + "/api/user/info"
        
        WebServiceBuilder.shared.getCall(serviceURL: userInfoURL, parameters: nil, headers: headerParameters, spinnerState: false, successCallback: { (successDict) in
            print("============ Get User Info Response")
            print(successDict)
            successCallback!(successDict)
        }) { (failureDict) in
            print(failureDict)
            failureCallback!(self.errorHandling(response: failureDict))
        }
    }
    
}
