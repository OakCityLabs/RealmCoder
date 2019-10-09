//
//  RealmCoder.swift
//  RealmCoder
//
//  Created by Jay Lyerly on 10/9/19.
//  Copyright © 2019 Oak City Labs. All rights reserved.
//

import Foundation
import RealmSwift

private typealias Json = [String: Any]

public enum RealmCoderError: Error {
    case unknownClass(String)
    case nonDictionaryTopLevelObject
    case nonArrayTopLevelObject
    case noKeysFound
    case primaryKeyNotFound
    case envelopeNotFound
}

private let iso8601Full: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}()

//private let JsonWritingOptions: JSONSerialization.WritingOptions = {
//    return [JSONSerialization.WritingOptions.sortedKeys
//}()

public class RealmCoder {
    
    let realm: Realm
    let dateFormatter: DateFormatter
    
    init(realm: Realm, dateFormatter: DateFormatter = iso8601Full) {
        self.realm = realm
        self.dateFormatter = dateFormatter
    }
    
}

// MARK: - Decoder
public extension RealmCoder {
    func decodeArray<T: Object>(_ type: T.Type, from data: Data) throws -> [T] {
        let jsonArray: [Json]
        
        if let envelope = type.realmListEnvelope {
            guard let json = try JSONSerialization.jsonObject(with: data) as? Json else {
                throw RealmCoderError.nonDictionaryTopLevelObject
            }

            guard let topDict = json as? [String: [Json]], let jArray = topDict[envelope] else {
                throw RealmCoderError.envelopeNotFound
            }
            jsonArray = jArray
        } else {
            guard let jArray = try JSONSerialization.jsonObject(with: data) as? [Json] else {
                throw RealmCoderError.nonArrayTopLevelObject
            }
            jsonArray = jArray
        }
    
        let objArray: [T] = try jsonArray.map { json in
            try decode(type, from: json, topLevel: false)
        }
        
        return objArray
    }
    
    func decode<T: Object>(_ type: T.Type, from data: Data) throws -> T {
        guard let json = try JSONSerialization.jsonObject(with: data) as? Json else {
            throw RealmCoderError.nonDictionaryTopLevelObject
        }
        
        return try decode(type, from: json)
    }
    
    func decode<T: Object>(_ type: T.Type, from inputJson: [String: Any], topLevel: Bool = true) throws -> T {
        
        let json: Json
        
        // Check the envelope but only if we're at the top level
        if let envelope = T.realmObjectEnvelope, topLevel {
            guard let input = inputJson as? [String: Json], let wrappedJson = input[envelope] else {
                throw RealmCoderError.envelopeNotFound
            }
            json = wrappedJson
        } else {
            json = inputJson
        }
        
        let moduleName = String(String(reflecting: type).split(separator: ".").first ?? "")
        let cDict = try creationDict(fromJson: json, forType: type, inModule: moduleName)
        
        realm.beginWrite()
        let shouldUpdate: Realm.UpdatePolicy = (T.primaryKey() != nil) ? .modified : .error
        let obj = realm.create(type, value: cDict, update: shouldUpdate)
        try realm.commitWrite()
        
        return obj
    }
    
    private func dictFrom(json: Json,
                          withClassName className: String,
                          withModule module: String = "") throws -> Json {
        let fullClassName = module.isEmpty ? className : "\(module).\(className)"
        let clz: Object.Type = (NSClassFromString(fullClassName) as? Object.Type)
            ?? Object.self
        let subDict = try creationDict(fromJson: json,
                                       forType: clz,
                                       inModule: module,
                                       nameMap: clz.realmCodableKeys,
                                       rawStringKeys: clz.realmCodableRawJsonSubstrings)
        return subDict
    }
    
    // FIXME:  Fix the swiftlint errors
    //swiftlint:disable:next cyclomatic_complexity function_body_length
    private func creationDict<T: Object>(fromJson json: Json,
                                         forType type: T.Type,
                                         inModule module: String,
                                         nameMap: [String: String] = T.realmCodableKeys,
                                         rawStringKeys: [String] = T.realmCodableRawJsonSubstrings ) throws -> Json {
        let className = String(describing: type)
                
        guard let objectSchema = realm.schema[className] else {
            throw RealmCoderError.unknownClass(className)
        }
        
        var cDict = Json()
        
        try objectSchema.properties.forEach { prop in
            let name = prop.name
            
            let jsonName = nameMap[name] ?? name
            guard let value = json[jsonName] else {
                // property not in dict
                return
            }
            if value is NSNull {
                // property value is missing
                return
            }
            
            switch prop.type {
            case .bool:
                if let boolValue = value as? Bool {
                    cDict[name] = boolValue
                }
            case .data:
                if let dataValue = value as? Data {
                    cDict[name] = dataValue
                }
            case .date:
                if let dateString = value as? String, let dateValue = dateFormatter.date(from: dateString) {
                    cDict[name] = dateValue
                }
            case .double:
                if let doubleValue = value as? Double {
                    cDict[name] = doubleValue
                }
            case .float:
                if let floatValue = value as? Float {
                    cDict[name] = floatValue
                }
            case .int:
                if let intValue = value as? Int {
                    cDict[name] = intValue
                }
            case .linkingObjects:
                break
            // FIXME: What to do with linking objects?
            case .object:
                if prop.isArray {
                    if let json = value as? [Json], let objClassName = prop.objectClassName {
                        cDict[name] = try json.map {
                            try dictFrom(json: $0,
                                         withClassName: objClassName,
                                         withModule: module)
                        }
                    }
                    
                } else {
                    if let json = value as? Json, let objClassName = prop.objectClassName {
                        cDict[name] = try dictFrom(json: json, withClassName: objClassName, withModule: module)
                    }
                }
            case .string:
                if rawStringKeys.contains(name) {
                    let dataValue = try JSONSerialization.data(withJSONObject: value, options: [.sortedKeys])
                    cDict[name] = String(data: dataValue, encoding: .utf8)
                } else {
                    if let stringValue = value as? String {
                        cDict[name] = stringValue
                    }
                }
            case .any:
                cDict[name] = value
            }
            
        }
        
        // If there's a primary key, make sure it was in the dictionary, otherwise throw an error.
        if let pKey = T.primaryKey() {
            if !cDict.keys.contains(pKey) {
                throw RealmCoderError.primaryKeyNotFound
            }
        }
        // If the dictionary is empty, throw an error so we don't create an empty object
        if cDict.isEmpty {
            throw RealmCoderError.noKeysFound
        }
        
        return cDict
    }
    
}

// MARK: - Encoder
public extension RealmCoder {
    
    func encodeArray<T: Object>(_ objArray: [T]) throws -> Data? {
        guard let jObj = objArray.json(withRealmCoder: self) else {
            return nil
        }
        
        let data = try JSONSerialization.data(withJSONObject: jObj,
                                              options: [.prettyPrinted, .sortedKeys])
        
        return data
    }

    func encode<T: Object>(_ object: T) throws -> Data? {
        
        guard let jObj = try object.json(withRealmCoder: self) else {
            return nil
        }
        
        let data = try JSONSerialization.data(withJSONObject: jObj,
                                              options: [.prettyPrinted, .sortedKeys])
        
        return data
    }
    
}

private protocol RealmJsonEncodable {
    func json(withRealmCoder coder: RealmCoder) throws -> Any?
}

extension List: RealmJsonEncodable where Element: Object {
    
    func json(withRealmCoder coder: RealmCoder) -> Any? {
        return Array(self.compactMap { try? $0.json(withRealmCoder: coder) })
    }
}


extension Array: RealmJsonEncodable where Element: Object {
    
    func json(withRealmCoder coder: RealmCoder) -> Any? {
        return self.compactMap { try? $0.json(withRealmCoder: coder) }
    }
}

extension Object: RealmJsonEncodable {
    
    func json(withRealmCoder coder: RealmCoder) throws -> Any? {
        
        var jDict = [String: Any]()
        
        let ignoredKeys = type(of: self).realmCodableIgnoredAttributes
        let nameMap = type(of: self).realmCodableKeys
        let rawStringKeys = type(of: self).realmCodableRawJsonSubstrings
        
        try objectSchema.properties.forEach { prop in
            let name = prop.name
            if ignoredKeys.contains(name) {
                return
            }
            let jsonName = nameMap[name] ?? name
            
            switch prop.type {
            case .string:
                if rawStringKeys.contains(name) {
                    // raw JSON is stored in the is string, so deserialize and use that value
                    let str = value(forKey: name) as? String
                    if let data = str?.data(using: .utf8) {
                        jDict[jsonName] = try JSONSerialization.jsonObject(with: data)
                    } else {
                        // globalDebug("Failed encode JSON data stored as string for key: \(name)")
                    }
                } else {
                    jDict[jsonName] = value(forKey: name)
                }
            case .bool, .data, .double, .float, .int, .any:
                jDict[jsonName] = value(forKey: name)
            case .date:
                if let date = value(forKey: name) as? Date {
                    jDict[jsonName] = coder.dateFormatter.string(from: date)
                }
            case .linkingObjects:
                break
            // FIXME: What to do with linking objects?
            case .object:
                if let value = value(forKey: name) as? RealmJsonEncodable {
                    jDict[jsonName] = try value.json(withRealmCoder: coder)
                }
            }
        }
        
        return jDict
    }
}
