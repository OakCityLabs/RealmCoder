//
//  NestedUser.swift
//  
//
//  Created by Jay Lyerly on 10/9/19.
//

import Foundation
import RealmSwift
import RealmCoder

class NestedUser: User {

    override class var realmObjectEnvelope: String? {
        return "user"
    }
    
    override class var realmListEnvelope: String? {
        return "users"
    }
}
