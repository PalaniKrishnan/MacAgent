/*
 * Copyright (c) 2022 Idemeum
 * All Rights Reserved.
 */

import Cocoa

@IBDesignable
class CustomTextField: NSTextField {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
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
    
    @IBInspectable var textIsMedium: Bool = false {
        didSet {
            setUpView()
        }
    }
    
    func setUpView() {
        self.bezelStyle = .squareBezel
        if textIsSemiBold {
            self.font = AppFont.RedHatDisplay_Bold.of(textFontSize)
        }else if textIsMedium {
            self.font = AppFont.RedHatDisplay_Medium.of(textFontSize)
        }else {
            self.font = AppFont.RedHatText_Regular.of(textFontSize)
        }
    }
    
}
