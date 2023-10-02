/*
 * Copyright (c) 2022 Idemeum
 * All Rights Reserved.
 */

import Foundation
import AppKit

extension String {
    
    func setBoldText(boldPartOfString: String, font: NSFont!, boldFont: NSFont!) -> NSAttributedString {
        let nonBoldFontAttribute = [NSAttributedString.Key.font:font!]
        let boldFontAttribute = [NSAttributedString.Key.font:boldFont!]
        let boldString = NSMutableAttributedString(string: self, attributes:nonBoldFontAttribute)
        let fullString:NSString = self as NSString
        boldString.addAttributes(boldFontAttribute, range: fullString.range(of: boldPartOfString))
        return boldString
    }
    
    func link_string(text:String, url:NSURL, font:NSFont) -> NSMutableAttributedString {
        // initially set viewable text
        let setFontAttribute = [NSAttributedString.Key.font:font]
        let attrString = NSMutableAttributedString(string: self, attributes: setFontAttribute)
        let fullString:NSString = self as NSString
        
        let linkAttribute = [NSAttributedString.Key.link:url.absoluteString!,// stack URL
                             NSAttributedString.Key.foregroundColor:NSColor.blue,// stack text color
                             //NSAttributedString.Key.underlineStyle:NSUnderlineStyle.single.rawValue// stack underline attribute
        ] as [NSAttributedString.Key : Any]
        
        attrString.addAttributes(linkAttribute, range: fullString.range(of: text))
        return attrString
    }
        
}

//MARK: Validation
extension String {
    
    var validOptionalString: String? {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty ? nil : self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    var isValidIdemeumDomain: Bool {
        return NSPredicate(format: "SELF MATCHES %@", Constant.domainRegex).evaluate(with: self)
    }
}
