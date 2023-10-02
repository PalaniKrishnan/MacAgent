/*
 * Copyright (c) 2022 Idemeum
 * All Rights Reserved.
 */

import Foundation
import AppKit


protocol ContainmentProvider: AnyObject {
    func add(asChildViewController viewController:NSViewController, to containerView: NSView)
    func remove(asChildViewController viewController:NSViewController?)
}

extension ContainmentProvider where Self: NSViewController {
    
    func add(asChildViewController viewController:NSViewController, to containerView: NSView) {
        DispatchQueue.main.async() {
            containerView.wantsLayer = true
            self.addChild(viewController)
            containerView.addSubview(viewController.view)
            
            viewController.view.wantsLayer = true
            viewController.view.frame = containerView.bounds
            viewController.view.layer?.autoresizingMask = [.layerHeightSizable, .layerWidthSizable]
        }
    }
    
    func remove(asChildViewController viewController:NSViewController?){
        DispatchQueue.main.async() {
            viewController?.view.removeFromSuperview()
            viewController?.removeFromParent()
        }
    }
}
