/*
 * Copyright (c) 2022 Idemeum
 * All Rights Reserved.
 */

import Cocoa

class UserModel:NSObject {
    static var shared = UserModel()
    var user:UserInfo?
}

// MARK: - User
struct UserInfo: Codable {
    let products: [String]?
    let clientAutoLockConfig: ClientAutoLockConfig?
    let details: UserDetails?
}

// MARK: - ClientAutoLockConfig
struct ClientAutoLockConfig: Codable {
    let enabled: Bool?
    let idleTimeoutInMintutes: Int?
}

// MARK: - Details
struct UserDetails: Codable {
    let status, fullyQualifiedDid, admin, id: String?
    let did, lastName, alternateFidoLoginDeviceRegistered, email: String?
    let department, alternateFidoLoginEnabled, firstName: String?

    enum CodingKeys: String, CodingKey {
        case status
        case fullyQualifiedDid = "fully_qualified_did"
        case admin, id, did
        case lastName = "last_name"
        case alternateFidoLoginDeviceRegistered, email, department, alternateFidoLoginEnabled
        case firstName = "first_name"
    }
}
