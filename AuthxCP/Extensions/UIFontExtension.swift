/*
 * Copyright (c) 2022 Idemeum
 * All Rights Reserved.
 */

import AppKit

//MARK:- AppFont
enum AppFont: String {
    /// DMSans
    case Inter_Regular = "Inter-Regular"
    case Inter_Bold = "Inter-Bold"
    case Inter_SemiBold = "Inter-SemiBold"
    case Inter_Medium = "Inter-Medium"
    
    case RedHatDisplay_Regular = "RedHatDisplay-Regular"
    case RedHatDisplay_Medium = "RedHatDisplay-Medium"
    case RedHatDisplay_Bold = "RedHatDisplay-Bold"
    
    case RedHatText_Regular = "RedHatText-Regular"
    case RedHatText_Medium = "RedHatText-Medium"
    case RedHatText_Bold = "RedHatText-Bold"
}

//MARK:- Other Methods
extension AppFont {
    
    func of(_ size: CGFloat) -> NSFont {
        return NSFont(name: self.rawValue, size: size)!
    }
}


