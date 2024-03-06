//
//  AppWindow.swift
//  AuthxMacOSAgent
//
//  Created by pkrishnan on 10/26/23.
//

import Cocoa

import IOKit
import IOKit.pwr_mgt


class AppWindow: NSWindow {
    

    override var canBecomeKey: Bool {
        self.setFrame(self.screen!.frame, display: true)
        self.contentView?.wantsLayer = true
        guard let frame = self.screen?.frame else {
            return false
        }
        self.contentView?.frame = NSRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
      
        
        let bottomViewFrame = NSRect(x: 0, y: 0, width: frame.size.width, height: 100)
        let bottomView = NSView(frame: bottomViewFrame)
        bottomView.wantsLayer = true
        bottomView.layer?.backgroundColor = .white
        self.contentView?.addSubview(bottomView)
        
       

        if let wifiImage = NSImage(systemSymbolName: "wifi", accessibilityDescription: nil)
        {
            let wifiImageView = NSImageView(image: wifiImage)
            wifiImageView.imageScaling = NSImageScaling.scaleAxesIndependently
            wifiImageView.frame = NSRect(x: frame.width-195, y: 25, width: 30, height: 20)
           // button.isBordered = false
            self.contentView?.addSubview(wifiImageView)
        }
        
        let poweredByLbl = NSTextField(frame: NSRect(x: frame.width - 160, y: 25, width: 100, height: 20))
        poweredByLbl.font = NSFont(name: "helvetica", size: 15)
        poweredByLbl.alignment = .left
        poweredByLbl.isEditable = false
        poweredByLbl.lineBreakMode = .byWordWrapping
        poweredByLbl.textColor = .gray
        poweredByLbl.isBordered = false
        poweredByLbl.stringValue = "Powered by"
        self.contentView?.addSubview(poweredByLbl)
        
        if let logoImage = NSImage(named: "authxLogo")
        {
            let logoImageView = NSImageView(image: logoImage)
            logoImageView.frame = NSRect(x: frame.width-70, y: 27, width: 60, height: 20)
            self.contentView?.addSubview(logoImageView)
        }
        
        return true
    }
    
    
}


