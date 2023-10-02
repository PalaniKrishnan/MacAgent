//
//  CheckAD.swift
//  NoMADLogin
//
//  Created by Joel Rennich on 9/20/17.
//  Copyright © 2017 Joel Rennich. All rights reserved.
//

import Cocoa
import os.log
import Security.AuthorizationPlugin
import SecurityInterface

class CheckAD: NSObject {
    @objc var signIn: AuthxLogIn!
    
    let mechCallbacks: AuthorizationCallbacks
    let mechEngine: AuthorizationEngineRef
    let mechView: SFAuthorizationPluginView
        
    @objc func run() {
        
        //NSApp.activate(ignoringOtherApps: true)
        signIn = AuthxLogIn(windowNibName: NSNib.Name("AuthxLogIn"))
        signIn.mechCallbacks = mechCallbacks
        signIn.mechEngine = mechEngine
        signIn.mechView = mechView
        signIn.showWindow(nil)        
        //NSApp.runModal(for: signIn.window!)
    }
    
    @objc init!(callbacks: UnsafePointer<AuthorizationCallbacks>!, andEngineRef engineRef: AuthorizationEngineRef!,engineView: SFAuthorizationPluginView!)
    {
        mechCallbacks = callbacks.pointee
        mechEngine = engineRef
        mechView = engineView
    }
    
    @objc func setAuthView(){
        
    }
    
        
    @objc func tearDown() {
        
    }
}
