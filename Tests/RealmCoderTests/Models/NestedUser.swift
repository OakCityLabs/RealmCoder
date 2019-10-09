//
//  NestedUser.swift
//  RealmCoderTests
//
//  Created by Jay Lyerly on 10/9/19.
//  Copyright © 2019 Oak City Labs. All rights reserved.
//

import Foundation
import RealmCoder
import RealmSwift

class NestedUser: User {

    override class var realmObjectEnvelope: String? {
        return "user"
    }
    
    override class var realmListEnvelope: String? {
        return "users"
    }
    
    // Flag the primary key for this object
    override class func primaryKey() -> String? {
        return "objId"
    }
}
