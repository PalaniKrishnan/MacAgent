/*
 * Copyright (c) 2022 Idemeum
 * All Rights Reserved.
 */

import Cocoa

@IBDesignable
class CustomView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    /*
     These click-blockers are required for the custom presented
     NSViewController's view, as it does not have it's own backing
     window. Without them, clicks are picked up by the buttons
     on the presentingViewControllers' view
     */
    override func mouseDown(with event: NSEvent) {}
    override func mouseDragged(with event: NSEvent) {}
    override func mouseUp(with event: NSEvent) {}
    
    
    @IBInspectable var BGColor: NSColor = .white {
        didSet {
            setUpView()
        }
    }
    
    @IBInspectable var cornerRadiusValue: CGFloat = 0.0 {
        didSet {
            setUpView()
        }
    }
    
    func setUpView() {
        self.wantsLayer = true
        self.layer?.backgroundColor = BGColor.cgColor
        self.layer?.cornerRadius = cornerRadiusValue
    }
    
}
