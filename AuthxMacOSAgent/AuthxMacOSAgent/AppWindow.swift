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
        guard let frame = self.screen?.frame else {
            return false
        }
        self.contentView?.frame = NSRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        self.contentView?.layer?.contents = NSImage(named: "passwordless-auth")
        
        let topViewFrame = NSRect(x: 0, y: frame.size.height-100, width: frame.size.width, height: 100)
        let topView = NSView(frame: topViewFrame)
        topView.wantsLayer = true
        topView.layer?.backgroundColor = .white
        self.contentView?.addSubview(topView)
        
        
        let bottomViewFrame = NSRect(x: 0, y: 0, width: frame.size.width, height: 100)
        let bottomView = NSView(frame: bottomViewFrame)
        bottomView.wantsLayer = true
        bottomView.layer?.backgroundColor = .white
        self.contentView?.addSubview(bottomView)
        
        if let powerImage = NSImage(named: "authxLogo")
        {
            let button = NSButton(image: powerImage, target: self, action: #selector(powerClicked))
            button.imageScaling = NSImageScaling.scaleProportionallyUpOrDown
            button.frame = NSRect(x: 20, y: frame.height-90, width: 80, height: 80)
            button.isBordered = false
            self.contentView?.addSubview(button)
        }
        
        if let powerImage = NSImage(systemSymbolName: "power.circle", accessibilityDescription: nil)
        {
            let button = NSButton(image: powerImage, target: self, action: #selector(powerClicked))
            button.imageScaling = NSImageScaling.scaleProportionallyUpOrDown
            button.frame = NSRect(x: 10, y: 10, width: 60, height: 60)
            button.isBordered = false
            self.contentView?.addSubview(button)
        }
        
        if let helpImage = NSImage(systemSymbolName: "questionmark.circle", accessibilityDescription: nil)
        {
            let button = NSButton(image: helpImage, target: self, action: #selector(helpClicked))
            button.imageScaling = NSImageScaling.scaleProportionallyUpOrDown
            button.isBordered = false
            button.frame = NSRect(x: 70, y: 10, width: 60, height: 60)
            self.contentView?.addSubview(button)
        }
        
        let bottomMsgLbl = NSTextField(frame: NSRect(x: (frame.width/2) - 100, y: 10, width: 200, height: 60))
        bottomMsgLbl.font = NSFont(name: "helvetica", size: 14)
        bottomMsgLbl.alignment = .center
        bottomMsgLbl.isEditable = false
        bottomMsgLbl.lineBreakMode = .byWordWrapping
        bottomMsgLbl.textColor = .gray
        bottomMsgLbl.isBordered = false
        bottomMsgLbl.stringValue = "This is for authorized personnel only"
        self.contentView?.addSubview(bottomMsgLbl)
        
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
    
    @objc func powerClicked() {
        print("power clicked")
    }
    
    @objc func helpClicked() {
        print("help clicked")
    }
    
}
