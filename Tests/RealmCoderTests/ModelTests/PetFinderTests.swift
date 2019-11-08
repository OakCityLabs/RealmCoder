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
    
    func testDecodeAnimalPhotosJson() throws {

        loadJson(fromFile: "pf_animals.json")
        
        do {
            let animals = try coder.decodeArray(Animal.self, from: jsonData)
            XCTAssertEqual(animals.count, 4)
            XCTAssertEqual(animals[0].photos.count, 0)
            XCTAssertEqual(animals[1].photos.count, 1)
            XCTAssertEqual(animals[2].photos.count, 1)
            XCTAssertEqual(animals[3].photos.count, 1)
            
            let photos = animals[1].photos
            XCTAssertEqual(photos[0].small,
                           "https://dl5zpyw5k3jeb.cloudfront.net/photos/pets/46492679/1/?bust=1573052354&width=100")
            XCTAssertEqual(photos[0].medium,
                           "https://dl5zpyw5k3jeb.cloudfront.net/photos/pets/46492679/1/?bust=1573052354&width=300")
            XCTAssertEqual(photos[0].large,
                           "https://dl5zpyw5k3jeb.cloudfront.net/photos/pets/46492679/1/?bust=1573052354&width=600")
            XCTAssertEqual(photos[0].full,
                           "https://dl5zpyw5k3jeb.cloudfront.net/photos/pets/46492679/1/?bust=1573052354")

        } catch {
            XCTFail("Failed to decode with error: \(error).")
        }
    }
    
    static var allTests = [
        ("testDecodeAnimalsJson", testDecodeAnimalsJson)
    ]
}
