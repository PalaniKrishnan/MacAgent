/*
 * Copyright (c) 2022 Idemeum
 * All Rights Reserved.
 */

import Foundation

class RSAManager {
    
    static func getPublicKeyFromBase64(_ base64String:String) -> SecKey? {
        //Convert "base 64 string" to Data
        guard let publicKeyData = Data(base64Encoded: base64String) else {
            return nil
        }
        
        var error: Unmanaged<CFError>?
        //Convert "Transient Public Key" Data to SecKey
        let attribute: [CFString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits: 2048,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
        ]
        //Generate public key key from Data.
        guard let publicKey = SecKeyCreateWithData(publicKeyData as NSData, attribute as NSDictionary, &error) else {
            return nil
        }
        return publicKey
    }
    
}
