/*
 * Copyright (c) 2022 Idemeum
 * All Rights Reserved.
 */

import Cocoa

@IBDesignable
class CustomButton: NSButton {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    @IBInspectable var cornerRadiusValue: CGFloat = 20.0 {
        didSet {
            setUpView()
        }
    }
    
    @IBInspectable var textFontSize: CGFloat = 14.0 {
        didSet {
            setUpView()
        }
    }
    
    @IBInspectable var textIsSemiBold: Bool = false {
        didSet {
            setUpView()
        }
    }
    
    @IBInspectable var BGColor: NSColor = .blue {
        didSet {
            setUpView()
        }
    }
    
    func setUpView() {
        self.wantsLayer = true
        self.layer?.backgroundColor = BGColor.cgColor
        self.bezelStyle = .texturedSquare
        self.isBordered = false //Important
        self.layer?.cornerRadius = self.cornerRadiusValue
        
        var btnFont = AppFont.RedHatText_Regular.of(textFontSize)
        
        if textIsSemiBold {
            btnFont = AppFont.RedHatText_Medium.of(textFontSize)
        }else{
            btnFont = AppFont.RedHatText_Regular.of(textFontSize)
        }
        
        let attributes = [NSAttributedString.Key.font: btnFont] as [NSAttributedString.Key : Any]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        self.attributedTitle = attributedTitle
    }
    
}
