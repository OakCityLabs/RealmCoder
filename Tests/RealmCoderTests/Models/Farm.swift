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

class Farm: Object {
    
    @objc dynamic var objId: String = ""
    @objc dynamic var updated: Date?
    @objc dynamic var name: String = ""
    @objc dynamic var area: Double = -1
    @objc dynamic var centroid: String = ""

    override class func primaryKey() -> String? {
        return "objId"
    }
    
    override class var realmCodableKeys: [String: String] {
        return [
            "objId": "uuid",
            "updated": "updated_at"
        ]
    }
    
    override class var realmCodableRawJsonSubstrings: [String] {
        return ["centroid"]
    }
}
