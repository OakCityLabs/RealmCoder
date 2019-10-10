//
//  Motorcycle.swift
//  RealmCoderTests
//
//  Created by Jay Lyerly on 10/10/19.
//  Copyright © 2019 Oak City Labs. All rights reserved.
//

import Foundation
import RealmCoder
import RealmSwift

class Motorcycle: Vehicle {
    
    @objc dynamic var rawType: String = ""
    
    override class var realmCodableKeys: [String: String] {
        return [
            "objId": "id",
            "rawType": "raw_type"
        ]
    }
}
