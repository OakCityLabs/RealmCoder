//
//  Vehicle.swift
//  RealmCoderTests
//
//  Created by Jay Lyerly on 10/10/19.
//  Copyright © 2019 Oak City Labs. All rights reserved.
//

import Foundation
import RealmCoder
import RealmSwift

class Vehicle: Object {
    
    @objc dynamic var objId: String = ""
    @objc dynamic var make: String = ""
    @objc dynamic var model: String = ""
    
    override class var realmCodableKeys: [String: String] {
        return [
            "objId": "id"
        ]
    }
}
