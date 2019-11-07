//
//  PetFinderTests.swift
//  RealmCoderTests
//
//  Created by Jay Lyerly on 10/9/19.
//  Copyright © 2019 Oak City Labs. All rights reserved.
//

import RealmCoder
import RealmSwift
import XCTest

/// Test Notes:
///     - Real data from the PetFinder v2 API
///     - Envelope originall cause the decoder to fail.
///

final class PetFinderTests: XCTestCase {
    var coder: RealmCoder!
    var jsonData: Data!
    
    override func setUp() {
        super.setUp()

        guard let realm = try? realmFactory() else {
            XCTFail("Can't get a realm from the factory.")
            return
        }
        coder = RealmCoder(realm: realm)
    }
    
    override func tearDown() {
        coder = nil
        jsonData = nil
        super.tearDown()
    }
    
    func loadJson(fromFile filename: String) {
        guard let data = data(fromFile: filename) else {
            XCTFail("Can't read test data from file \(filename)")
            return
        }
        jsonData = data
    }
    
    func testDecodeAnimalsJson() throws {

        loadJson(fromFile: "pf_animals.json")
        
        do {
            let animals = try coder.decodeArray(Animal.self, from: jsonData)
            XCTAssertEqual(animals.count, 4)
            XCTAssertEqual(animals[0].name, "BARNABY")
            XCTAssertEqual(animals[1].name, "COAL")
            XCTAssertEqual(animals[2].name, "DARLA")
            XCTAssertEqual(animals[3].name, "CAMILLA")
        } catch {
            XCTFail("Failed to decode with error: \(error).")
        }
    }
    
    
    static var allTests = [
        ("testDecodeAnimalsJson", testDecodeAnimalsJson)
    ]
}
