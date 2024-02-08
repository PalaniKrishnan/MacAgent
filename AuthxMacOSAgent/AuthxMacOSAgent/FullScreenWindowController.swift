//
//  FullScreenWindowController.swift
//  AuthxMacOSAgent
//
//  Created by pkrishnan on 10/12/23.
//

import Cocoa


class FullScreenWindowController: NSWindowController {

    override func windowDidLoad() {
        window?.styleMask = .borderless
        // Dock and Menu Bar are completely inaccessible
        // NSApplication.shared.presentationOptions = [.hideDock, .hideMenuBar]
        // Dock and Menu Bar will automatically hide when not needed
        NSApplication.shared.presentationOptions = [.autoHideDock, .autoHideMenuBar]
        window?.makeKeyAndOrderFront(self)
      // window?.orderFrontRegardless()
    }
}




