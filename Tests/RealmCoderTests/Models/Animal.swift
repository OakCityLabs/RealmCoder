//
//  EnvelopedUser.swift
//  RealmCoderTests
//
//  Created by Jay Lyerly on 11/7/19.
//  Copyright © 2019 Oak City Labs. All rights reserved.
//

import Foundation
import RealmCoder
import RealmSwift

class Animal: Object {

    @objc dynamic var objId: Int = -1
    @objc dynamic var name: String = ""
    @objc dynamic var type: String = ""

    var photos = List<Photo>()

    override class var realmCodableKeys: [String: String] {
        return ["objId": "id"]
    }
    
    override class var realmListEnvelope: String? {
        return "animals"
    }
    
    // Flag the primary key for this object
    override class func primaryKey() -> String? {
        return "objId"
    }
    
}

class Photo: Object {
    @objc dynamic var small: String?
    @objc dynamic var medium: String?
    @objc dynamic var large: String?
    @objc dynamic var full: String?
}
