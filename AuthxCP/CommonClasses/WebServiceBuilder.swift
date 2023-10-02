/*
 * Copyright (c) 2022 Idemeum
 * All Rights Reserved.
 */

import Foundation
import Alamofire
import SwiftSoup

class WebServiceBuilder: NSObject {
    
    static let shared = WebServiceBuilder()
    
    let requestTimeout:TimeInterval = 60.0
    
    //MARK: - Closures
    typealias successClosure = (Dictionary<String, Any>) -> Void
    typealias failureClosure = (Dictionary<String, Any>) -> Void

    
    //MARK: API call GET, POST
    
    func getCall(serviceURL: String, parameters: [String:Any]?, headers: HTTPHeaders, spinnerState: Bool, successCallback: successClosure?, failureCallback: failureClosure?) {
        if !CommonFunctions.isConnectedToInternet() {
            CommonFunctions.showNSAlert(title: Constant.AlertTitle.noInternet, message: Constant.Message.noInternetMsg, button: Constant.AlertButtonTitle.Ok, buttonAction: nil)
            failureCallback!(["error_description":"Internet not available."])
        } else {
            URLCache.shared.removeAllCachedResponses()
            let manager = Alamofire.Session.default
            let cstorage = manager.sessionConfiguration.httpCookieStorage
            if let url = URL(string: serviceURL), let cookies = cstorage?.cookies(for: url) {
                for cookie in cookies {
                    cstorage?.deleteCookie(cookie)
                }
            }
            manager.session.configuration.requestCachePolicy = .reloadIgnoringCacheData
            manager.session.configuration.urlCache = nil
            manager.session.configuration.httpShouldSetCookies = false
            manager.session.configuration.timeoutIntervalForRequest = requestTimeout
           
            manager.request(serviceURL, method: .get, parameters: parameters, encoding: JSONEncoding(), headers: headers).responseJSON { (response) in
                                
                //This is only for internal login API. HTML parse.
                if let data = response.data, let URL = response.request?.url, URL.absoluteString.contains("internal/login") {
                    if let html = String(data: data, encoding: .utf8) {
                        do {
                            let doc: Document = try SwiftSoup.parse(html)
                            if let csrfTokenValue = try doc.getElementById(Constant.Key.csrfToken)?.val(),
                               let loginCtxIdValue = try doc.getElementById(Constant.Key.loginCtxId)?.val() {
                                let resultDic:[String:Any] = [Constant.Key.csrfToken:csrfTokenValue, Constant.Key.loginCtxId: loginCtxIdValue]
                                successCallback!(resultDic)
                                return
                            }
                        } catch {
                            print("error", error.localizedDescription)
                        }
                    }
                }
                
                //This is only for Signin Polling API.
                if let headerFields = response.response?.allHeaderFields as? [String: String], let URL = response.request?.url , URL.absoluteString.contains("signin/v2/polling?signinId=") {
                    let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: URL)
                    
                    var cookieDict = [String : Any]()
                    for cookie in cookies {
                        if cookie.name == Constant.Key.idemeumToken || cookie.name == Constant.Key.DVMI_ID {
                            cookieDict[cookie.name] = cookie.properties![HTTPCookiePropertyKey(rawValue: "Value")] as? String
                            //cookieDict["domain"] = cookie.domain
                        }
                    }
                    if cookieDict.count > 0 {
                        cookieDict[Constant.Key.status] = SigninPollingStatus.COMPLETED.rawValue
                        successCallback!(cookieDict)
                        return
                    }
                }
                
                //This is only for user portal API. HTML parse.
                if let data = response.data, let URL = response.request?.url, let headerFields = response.response?.allHeaderFields as? [String: String], URL.absoluteString.contains("userportal") {
                    var resultDic:[String:Any] = [:]
                    //============ Get data from header cookies
                    let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: URL)
                    for cookie in cookies {
                        if cookie.name == Constant.Key.idemeum_CSRF {
                            resultDic[cookie.name] = cookie.properties![HTTPCookiePropertyKey(rawValue: "Value")] as? String
                        }
                    }
                    //============ Get data from HTML.
                    if let html = String(data: data, encoding: .utf8) {
                        do {
                            let doc: Document = try SwiftSoup.parse(html)
                            if let hdnXIdemeumCSRFToken = try doc.getElementById(Constant.Key.hdnXIdemeumCSRFToken)?.val() {
                                resultDic [Constant.Key.hdnXIdemeumCSRFToken] = hdnXIdemeumCSRFToken
                                successCallback!(resultDic)
                                return
                            }
                        } catch {
                            print("error", error.localizedDescription)
                        }
                    }
                }
                
                
                switch response.result {
                case .success(let value):
                    guard let responseDict = value as? [String:Any] else{
                        if response.response?.statusCode == 204 {
                            successCallback!([:])
                            return
                        }
                        failureCallback!([:])
                        return
                    }

                    if let anyError = responseDict["error"] as? String, anyError != "" {
                        failureCallback!(["error_description":responseDict["error"] as? String ?? "", "error" :anyError])
                    }else if let anyErrorCode = responseDict["code"] as? String, anyErrorCode != "" {
                        failureCallback!(["error_description":responseDict["message"] as? String ?? "", "error" :anyErrorCode])
                    }else if let anyErrorCode = responseDict["code"] as? Int, (200...299).contains(anyErrorCode) == false { //anyErrorCode == 400
                        failureCallback!(["error_description":responseDict["message"] as? String ?? "", "error" :anyErrorCode])
                    }else{
                        successCallback!(responseDict)
                    }
                case .failure(let error):
                    failureCallback!(["error_description": error.localizedDescription ])
                }
            }
        }
    }
   
    func postCall(serviceURL: String, parameters: [String:Any]?, headers: HTTPHeaders, spinnerState: Bool, successCallback: successClosure?, failureCallback: failureClosure?) {
        if !CommonFunctions.isConnectedToInternet() {
            CommonFunctions.showNSAlert(title: Constant.AlertTitle.noInternet, message: Constant.Message.noInternetMsg, button: Constant.AlertButtonTitle.Ok, buttonAction: nil)
            failureCallback!(["error_description":"Internet not available."])
        } else {
            let manager = Alamofire.Session.default
            manager.session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
            manager.session.configuration.urlCache = nil
            manager.session.configuration.timeoutIntervalForRequest = requestTimeout
            manager.request(serviceURL, method: .post, parameters: parameters, encoding: JSONEncoding(), headers: headers).responseJSON { (response) in
                    
                switch response.result {
                case .success(let value):
   
                    guard let responseDict = value as? [String:Any] else{
                        if response.response?.statusCode == 204 {
                            successCallback!([:])
                            return
                        }
                        failureCallback!([:])
                        return
                    }
                    
                    if let anyError = responseDict["error"] as? String, anyError != "" {
                        failureCallback!(["error_description":responseDict["message"] as? String ?? "", "error" :anyError])
                    }else if let anyErrorCode = responseDict["code"] as? String, anyErrorCode != "" {
                        failureCallback!(["error_description":responseDict["message"] as? String ?? "", "error" :anyErrorCode])
                    }else if let anyErrorCode = responseDict["code"] as? Int, (200...299).contains(anyErrorCode) == false { //anyErrorCode == 400
                        failureCallback!(["error_description":responseDict["message"] as? String ?? "", "error" :anyErrorCode])
                    }else{
                        successCallback!(responseDict)
                    }
                case .failure(let error):
                    failureCallback!(["error_description": error.localizedDescription ])
                }
            }
        }
    }
    
    func patchCall(serviceURL: String, parameters: [String:Any]?, headers: HTTPHeaders, spinnerState: Bool, successCallback: successClosure?, failureCallback: failureClosure?) {
        if !CommonFunctions.isConnectedToInternet() {
            CommonFunctions.showNSAlert(title: Constant.AlertTitle.noInternet, message: Constant.Message.noInternetMsg, button: Constant.AlertButtonTitle.Ok, buttonAction: nil)
            failureCallback!(["error_description":"Internet not available."])
        } else {
            let manager = Alamofire.Session.default
            manager.session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
            manager.session.configuration.urlCache = nil
            manager.session.configuration.timeoutIntervalForRequest = requestTimeout
            manager.request(serviceURL, method: .patch, parameters: parameters, encoding: JSONEncoding(), headers: headers).responseJSON { (response) in
                    
                switch response.result {
                case .success(let value):
   
                    guard let responseDict = value as? [String:Any] else{
                        if response.response?.statusCode == 204 {
                            successCallback!([:])
                            return
                        }
                        failureCallback!([:])
                        return
                    }
                    
                    if let anyError = responseDict["error"] as? String, anyError != "" {
                        failureCallback!(["error_description":responseDict["message"] as? String ?? "", "error" :anyError])
                    }else if let anyErrorCode = responseDict["code"] as? String, anyErrorCode != "" {
                        failureCallback!(["error_description":responseDict["message"] as? String ?? "", "error" :anyErrorCode])
                    }else if let anyErrorCode = responseDict["code"] as? Int, (200...299).contains(anyErrorCode) == false { //anyErrorCode == 400
                        failureCallback!(["error_description":responseDict["message"] as? String ?? "", "error" :anyErrorCode])
                    }else{
                        successCallback!(responseDict)
                    }
                case .failure(let error):
                    failureCallback!(["error_description": error.localizedDescription ])
                }
            }
        }
    }
    
}
