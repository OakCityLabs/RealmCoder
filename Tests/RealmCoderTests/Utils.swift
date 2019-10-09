//
//  Utils.swift
//  RealmCoderTests
//
//  Created by Jay Lyerly on 10/9/19.
//  Copyright © 2019 Oak City Labs. All rights reserved.
//

import Foundation
import RealmSwift

let testRealmConfig: Realm.Configuration = {
    let memId = UUID().uuidString
    let config = Realm.Configuration(inMemoryIdentifier: memId)
    return config
}()

func realmFactory() throws -> Realm {
    return try Realm(configuration: testRealmConfig)
}

/// Return data read from a file in the Data directory.
/// - Parameter filename: Filename of target file with respect to the Data directory
func data(fromFile filename: String) -> Data? {
    guard let url = url(toFile: filename) else {
        return nil
    }
    return try? Data(contentsOf: url)
}

/// Find a URL to a file in the Data directory.
/// - Parameter filename: Filename of target file with respect to the Data directory
func url(toFile filename: String) -> URL? {
    let thisSourceFile = URL(fileURLWithPath: #file)
    let thisDirectory = thisSourceFile.deletingLastPathComponent()
    let dataDirectory = thisDirectory.appendingPathComponent("Data", isDirectory: true)
    let resourceURL = dataDirectory.appendingPathComponent(filename)
    return resourceURL
}
