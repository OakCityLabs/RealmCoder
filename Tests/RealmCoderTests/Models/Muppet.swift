//
//  Farm.swift
//  RealmCoderTests
//
//  Created by Jay Lyerly on 10/10/19.
//  Copyright © 2019 Oak City Labs. All rights reserved.
//

import Foundation
import RealmCoder
import RealmSwift

class Muppet: Object {
    
    @objc dynamic var objId: String = ""
    @objc dynamic var name: String?
    @objc dynamic var species: String?
    @objc dynamic var gender: String?
    @objc dynamic var occupation: String?

    override class func primaryKey() -> String? {
        return "objId"
    }
    
    override class var realmCodableKeys: [String: String] {
        return [
            "objId": "id"
        ]
    }
}
