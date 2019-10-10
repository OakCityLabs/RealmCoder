//
//  FarmTests.swift
//  RealmCoderTests
//
//  Created by Jay Lyerly on 10/9/19.
//  Copyright © 2019 Oak City Labs. All rights reserved.
//

import RealmCoder
import RealmSwift
import XCTest

/// Test Notes:
///     ParkingLotTests excercises these specific aspects of the RealmCoder
///     - Date parsing with an init-time specified dataformatter
///     - Storing a chunk of the JSON blob as a raw string
///

private let fsFarmDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "E, d MMM yyyy HH:mm:ss zzz"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}()

final class FarmTests: XCTestCase {
    var coder: RealmCoder!
    var jsonData: Data!
    
    override func setUp() {
        super.setUp()

        guard let realm = try? realmFactory() else {
            XCTFail("Can't get a realm from the factory.")
            return
        }
        coder = RealmCoder(realm: realm, dateFormatter: fsFarmDateFormatter)
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
        
    func testDecodeFarmJson() throws {

        loadJson(fromFile: "farm.json")
        
        let farm = try coder.decode(Farm.self, from: jsonData)
        
        let expectedCentroid = """
        {"coordinates":[-2,52],"crs":{"properties":{"name":"EPSG:4326"},"type":"name"},"type":"Point"}
        """
        XCTAssertEqual(farm.area, 71_435.715)
        XCTAssertEqual(farm.name, "Stardew Valley")
        XCTAssertEqual(farm.updated,
                       Date(timeIntervalSince1970: 1_526_655_217))      // Friday, May 18, 2018 2:53:37 PM GMT
        XCTAssertEqual(farm.objId, "ae0ab025-6471-46b1-b008-b01ba95556bf")
        XCTAssertEqual(farm.centroid, expectedCentroid)
    }

    static var allTests = [
        ("testDecodeFarmJson", testDecodeFarmJson)
    ]
}
