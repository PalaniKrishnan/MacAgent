/*
 * Copyright (c) 2022 Idemeum
 * All Rights Reserved.
 */

import Cocoa

class TenantModel: NSObject {

    static var shared = TenantModel()
    
    var urlString:String = ""
    var csrfToken:String = ""
    var loginCtxId:String = ""
}
