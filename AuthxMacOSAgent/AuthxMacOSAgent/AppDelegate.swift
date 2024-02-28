//
//  AppDelegate.swift
//  zKeyRegistration
//
//  Created by Shahzad on 10/10/19.
//  Copyright © 2019 Shahzad. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var appBecomingActive: (()->())?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        print("applicationDidBecomeActive")
        appBecomingActive?()
    }

}

