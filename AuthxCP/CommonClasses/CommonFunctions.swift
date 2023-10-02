/*
 * Copyright (c) 2022 Idemeum
 * All Rights Reserved.
 */

import Foundation
import Alamofire


class CommonFunctions: NSObject {
    static let shared = CommonFunctions()
    
    static var backgroundView:CustomView?
    
    // MARK: - show NSAlert View
    class func showNSAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: Constant.AlertButtonTitle.Ok)
        alert.runModal()
    }
    
    class func showNSAlert(title: String, message: String, button: String, buttonAction: (()->Void)? = nil) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: button)
        let modelResult = alert.runModal()
        if modelResult == .alertFirstButtonReturn {
            print("OK Clicked...")
            buttonAction?()
        }
    }
    
    // MARK: - Internet Connectivity Methods
    class func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
    //MARK: - Activity Indicator Methods
    class func showProgressIndicator(_ view:NSView) {
        if let _ = backgroundView {
            backgroundView?.removeFromSuperview()
        }
        backgroundView = CustomView()
        backgroundView!.frame = view.bounds
        backgroundView!.wantsLayer = true
        backgroundView!.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.4).cgColor
        
        let sizeOfIndicator:CGFloat = 36.0
        let x = (backgroundView!.bounds.width - sizeOfIndicator) * 0.5
        let y = (backgroundView!.bounds.height - sizeOfIndicator) * 0.5
        let f = CGRect(x: x, y: y, width: sizeOfIndicator, height: sizeOfIndicator)
        
        let progressbar = NSProgressIndicator(frame: f)
        progressbar.autoresizingMask = [.minXMargin, .maxXMargin, .minYMargin, .maxYMargin ]
        progressbar.isIndeterminate = true
        progressbar.style = .spinning
        backgroundView!.addSubview(progressbar)
        progressbar.startAnimation(nil)
        
        view.addSubview(backgroundView!)
    }
    
    class func hideProgressIndicator() {
        DispatchQueue.main.async {
            backgroundView?.removeFromSuperview()
        }
    }
    
    
    //MARK: Create a secret for TOTP
    class func generateSharedSecret(length:Int) -> String? {
        
        var arrBytes = Array(65...90)//A-Z
        arrBytes.append(contentsOf: Array(50...55)) //2-7
        let randomBytes = secureRandom(charLength: length, rangeBytes:arrBytes) //array of secure bytes (Ascii value).
        
        guard let secureString = String(bytes: randomBytes, encoding: .utf8) else { //Convert bytes (Ascii) to character.
            return nil
        }
        
        return String(Array(secureString).shuffled())
    }
        
    class func secureRandom(charLength:Int, rangeBytes:[Int]) -> [UInt8] {
        var bytesArray:[UInt8] = []
        while bytesArray.count != charLength {
            var bytes = [UInt8](repeating: 0, count: 1)
            let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
            //print("bytes :: ", bytes)
            if status == errSecSuccess, rangeBytes.contains(Int(bytes.first!)){ // Always test the status.
                bytesArray.append(bytes.first!)
            }
        }
        return bytesArray
    }
    
    //MARK: - User Defaults.
    class func saveDataToUserDefaults(_ data:Any, forKey:String) {
        let defaults = UserDefaults.standard
        defaults.setValue(data, forKey: forKey)
        defaults.synchronize()
    }
    
    class func getDataFromUserDefaults(_ forKey:String) -> Any? {
        let defaults = UserDefaults.standard
        let data = defaults.value(forKey: forKey)
        return data
    }
}
