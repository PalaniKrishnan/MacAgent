//
//  AppWindow.swift
//  AuthxMacOSAgent
//
//  Created by pkrishnan on 10/26/23.
//

import Cocoa

class AppWindow: NSWindow {
    
    override var canBecomeKey: Bool {
        self.setFrame(self.screen!.frame, display: true)
        self.contentView?.wantsLayer = true
        if let frame = self.screen?.frame {
            self.contentView?.frame = NSRect(x: 0, y: 100, width: frame.size.width, height: frame.size.height-200)
        }
        self.contentView?.layer?.contents = NSImage(named: "passwordless-auth")
        return true
    }
    
}
