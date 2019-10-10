//
//  Car.swift
//  RealmCoderTests
//
//  Created by Jay Lyerly on 10/10/19.
//  Copyright © 2019 Oak City Labs. All rights reserved.
//

import Foundation
import RealmCoder
import RealmSwift

class Car: Vehicle {
    
    @objc dynamic var doorCount: Int = 0
    @objc dynamic var wheelCount: Int = 0
    
    override class var realmCodableKeys: [String: String] {
        return [
            "objId": "id",
            "doorCount": "door_count",
            "wheelCount": "wheel_count"
        ]
    }
}
