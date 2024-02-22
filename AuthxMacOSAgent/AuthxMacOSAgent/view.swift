//
//  view.swift
//  AuthxMacOSAgent
//
//  Created by pkrishnan on 2/15/24.
//

import AppKit
import Foundation

extension NSView {

    var backgroundColor: NSColor? {

        get {
            if let colorRef = self.layer?.backgroundColor {
                return NSColor(cgColor: colorRef)
            } else {
                return nil
            }
        }

        set {
            self.wantsLayer = true
            self.layer?.backgroundColor = newValue?.cgColor
        }
    }
    
}

@IBDesignable public class RoundedView: NSView {

    @IBInspectable var borderColor: NSColor = NSColor.white {
        didSet {
            layer?.borderColor = borderColor.cgColor
            layer?.masksToBounds = true
        }
    }

    @IBInspectable var borderWidth: CGFloat = 2.0 {
        didSet {
            layer?.borderWidth = borderWidth
            layer?.masksToBounds = true
        }
    }

    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer?.cornerRadius = cornerRadius
            layer?.masksToBounds = true
        }
    }

}
