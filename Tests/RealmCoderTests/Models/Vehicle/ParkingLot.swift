
//
//  ParkingLot.swift
//  RealmCoderTests
//
//  Created by Jay Lyerly on 10/10/19.
//  Copyright © 2019 Oak City Labs. All rights reserved.
//

import Foundation
import RealmCoder
import RealmSwift

class ParkingLot: Object {
    
    @objc dynamic var objId: String = ""
    @objc dynamic var name: String = ""
    
    var cars = List<Car>()
    var motorcycles = List<Motorcycle>()
    
    override class var realmCodableKeys: [String: String] {
        return [
            "objId": "id"
        ]
    }
    
    override class var realmObjectEnvelope: String? {
        return "parking_lot"
    }
}
