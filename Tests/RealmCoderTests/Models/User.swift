//
//  User.swift
//  
//
//  Created by Jay Lyerly on 10/9/19.
//

import Foundation
import RealmSwift
import RealmCoder

class User: Object {
    
    @objc dynamic var objId: String = ""
    @objc dynamic var rank: Int = -1
    @objc dynamic var username: String = ""
    @objc dynamic var firstName: String = ""
    @objc dynamic var lastName: String = ""
    
    override class var realmCodableKeys: [String: String] {
        return [
            "firstName": "first_name",
            "lastName": "last_name",
            "objId": "id"
        ]
    }
}
