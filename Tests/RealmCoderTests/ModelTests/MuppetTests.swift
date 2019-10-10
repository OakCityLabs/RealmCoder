//
//  MuppetTests.swift
//  RealmCoderTests
//
//  Created by Jay Lyerly on 10/9/19.
//  Copyright © 2019 Oak City Labs. All rights reserved.
//

import RealmCoder
import RealmSwift
import XCTest

/// Test Notes:
///     MuppetTests excercises these specific aspects of the RealmCoder
///     - Updating objects identified by primary key from multiple JSON chunks
///

final class MuppetTests: XCTestCase {
    var coder: RealmCoder!

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
        super.tearDown()
    }
    
    func loadJson(fromFile filename: String) -> Data? {
        guard let data = data(fromFile: filename) else {
            XCTFail("Can't read test data from file \(filename)")
            return nil
        }
        return data
    }
        
    func testDecodeMuppetJson() throws {

        let data1 = loadJson(fromFile: "muppet_part1.json")!
        let data2 = loadJson(fromFile: "muppet_part2.json")!

        let muppet = try coder.decode(Muppet.self, from: data1)
        
        XCTAssertEqual(muppet.objId, "qwerqer-xvbxvb-asdfasdfas")
        XCTAssertEqual(muppet.name, "Fozzie")
        XCTAssertEqual(muppet.gender, "male")
        XCTAssertNil(muppet.species)
        XCTAssertNil(muppet.occupation)
        
        let muppet2 = try coder.decode(Muppet.self, from: data2)
        XCTAssertEqual(muppet2.objId, "qwerqer-xvbxvb-asdfasdfas")
        XCTAssertEqual(muppet2.name, "Fozzie")
        XCTAssertEqual(muppet2.gender, "male")
        XCTAssertEqual(muppet2.species, "bear")
        XCTAssertEqual(muppet2.occupation, "comedian")
    }

    static var allTests = [
        ("testDecodeMuppetJson", testDecodeMuppetJson)
    ]
}
