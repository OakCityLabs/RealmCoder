//
//  RealmCodable.swift
//  
//
//  Created by Jay Lyerly on 10/9/19.
//

import Foundation
import RealmSwift

@objc
public protocol RealmCodable {
    static var realmCodableKeys: [String: String] { get }
    static var realmCodableIgnoredAttributes: [String] { get }
}

@objc
extension Object: RealmCodable {
    // Mapping of keynames from Realm keys to JSON keys
    // The keys of this dictionary correspond to Realm keys.
    // The values correspond to JSON keys
    open class var realmCodableKeys: [String: String] {
        return [:]
    }
    
    // A list of attribute names to ignore when encoding JSON data.
    // The value of these keys will not appear in the encoded JSON.
    open class var realmCodableIgnoredAttributes: [String] {
        return []
    }
    
    // A list of attributes that, when mapping the JSON data, should be
    // set to a raw string of the sub-JSON object.
    // The result is that these attributes (which must be String types)
    // will contain a string that is a raw JSON encoding of the sub-object
    open class var realmCodableRawJsonSubstrings: [String] {
        return []
    }
}

public protocol RealmResponseEnveloped {
    var envelope: String? { get }
//    var listEnvelope: String? { get }
}

extension Object: RealmResponseEnveloped {
    open var envelope: String? {
        return nil
    }
    
//    var listEnvelope: String? {
//        return nil
//    }
}

//protocol ResourcePageable {}   // Resource can be paged
//protocol ElementPageable {}    // Element where an Array can be paged
//
//extension Array: ResourcePageable where Element: ElementPageable {}
