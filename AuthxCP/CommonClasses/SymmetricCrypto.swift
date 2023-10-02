/*
 * Copyright (c) 2022 Idemeum
 * All Rights Reserved.
 */

import Cocoa
import CryptoKit

class SymmetricCrypto: NSObject {
    
    static var shared = SymmetricCrypto()
    
    var secureKey:String?

    //Create a secure key (AES-GCM 256 bit)
    static func generateSecureKey() -> String {
        
        //generate Symmetric  key
        let key = SymmetricKey(size: .bits256)
        //Get symmetric key data
        let symmetricKey = key.withUnsafeBytes {Data(Array($0)).base64EncodedString()}
        
        return symmetricKey
    }
    
    static func getEncryptedSecureKey(_ secureKey:String, publicKeyBase64:String) -> String? {
        //==================================================================================//
        //==================== Encrypt secure key using user public key ====================//
        //==================================================================================//

        guard let publicKey = RSAManager.getPublicKeyFromBase64(publicKeyBase64) else{
            return nil
        }
        
       //secure key to data
        guard let secureKeyData = Data(base64Encoded: secureKey) else {
            return nil
        }

        let algorithm: SecKeyAlgorithm = .rsaEncryptionOAEPSHA1
        
        var error: Unmanaged<CFError>?
        //Encryption
        guard let cipherText = SecKeyCreateEncryptedData(publicKey, algorithm, secureKeyData as CFData, &error) as Data? else {
            print(error ?? "")
            return nil
        }
        let encryptedSecureKey = cipherText.base64EncodedString()
        
        return encryptedSecureKey
    }
    
    static func getEncryptedSharedSecret(mfaSecret:String, secureKey:String) -> String? {
        
        //=========================================================================//
        //========= Encrypt MFASecter using secure key (symmetric key) ============//
        //=========================================================================//
        
        let keyData = Data(base64Encoded: secureKey)
        let key = SymmetricKey(data: keyData!)
        
        //Convert plaintext to data.
        guard let MFAtextData = mfaSecret.data(using: .utf8) else {
            return nil
        }
        
        //encrypt plaintext
        let encryptedMFASecretData = try!  AES.GCM.seal(MFAtextData, using: key)
        guard let combinedMFAData = encryptedMFASecretData.combined else{
            return nil
        }
        
        let MFAivBase64 = combinedMFAData.subdata(in: 0 ..< 12).base64EncodedString() //First 12 Bytes is IV
        let encryptMFASecretBase64 = combinedMFAData.subdata(in: 12 ..< combinedMFAData.count).base64EncodedString() //Other bytes is encrypted text
        
        let encryptedSharedSecret = "\(encryptMFASecretBase64)::\(MFAivBase64)"
        return encryptedSharedSecret
    }
    
}
