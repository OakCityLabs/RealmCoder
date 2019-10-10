//
//  ParkingLotTests.swift
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
///     - Nested data structures -- a parking lot has a list of cars and motorcycles, defined in the JSON
///     - Compatibility with models which are subclassed from another model.
///

final class ParkingLotTests: XCTestCase {
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
        
    func testDecodeParkingLotJson() throws {

        loadJson(fromFile: "parking_lot.json")
        
        let pLot = try coder.decode(ParkingLot.self, from: jsonData)
        
        XCTAssertEqual(pLot.name, "Lot 1")
        XCTAssertEqual(pLot.objId, "0104-47-2394")
        XCTAssertEqual(pLot.cars.count, 3)
        XCTAssertEqual(pLot.motorcycles.count, 2)
        
        let car0 = pLot.cars[0]
        let car1 = pLot.cars[1]
        let car2 = pLot.cars[2]
        
        XCTAssertEqual(car0.objId, "qwfqwf")
        XCTAssertEqual(car0.make, "chevy")
        XCTAssertEqual(car0.model, "cavalier")
        XCTAssertEqual(car0.doorCount, 5)
        XCTAssertEqual(car0.wheelCount, 4)
        
        XCTAssertEqual(car1.objId, "zfdfaf")
        XCTAssertEqual(car1.make, "honda")
        XCTAssertEqual(car1.model, "del Sol")
        XCTAssertEqual(car1.doorCount, 2)
        XCTAssertEqual(car1.wheelCount, 4)
        
        XCTAssertEqual(car2.objId, "poupouii")
        XCTAssertEqual(car2.make, "reliant")
        XCTAssertEqual(car2.model, "robin")
        XCTAssertEqual(car2.doorCount, 2)
        XCTAssertEqual(car2.wheelCount, 3)
        
        let cycle0 = pLot.motorcycles[0]
        let cycle1 = pLot.motorcycles[1]
        
        XCTAssertEqual(cycle0.objId, "oiyoiuy")
        XCTAssertEqual(cycle0.make, "kawasaki")
        XCTAssertEqual(cycle0.model, "howitzer")
        XCTAssertEqual(cycle0.rawType, "dirt")

        XCTAssertEqual(cycle1.objId, "hlglkjh")
        XCTAssertEqual(cycle1.make, "honda")
        XCTAssertEqual(cycle1.model, "goldwing")
        XCTAssertEqual(cycle1.rawType, "cruiser")
    }
    
    func testEncodeParkingLotJson() throws {
        
        loadJson(fromFile: "parking_lot_encode.json")
        
        let cycle = Motorcycle()
        cycle.objId = "930303-38383"
        cycle.make = "Harley Davidson"
        cycle.model = "Shovelhead"
        cycle.rawType = "street"
        
        let car = Car()
        car.objId = "woddjelsadfj"
        car.make = "Volkswagen"
        car.model = "R32"
        car.doorCount = 3
        car.wheelCount = 4
        
        let otherCar = Car()
        otherCar.objId = "zxc.vqwie"
        otherCar.make = "MINI"
        otherCar.model = "Cooper"
        otherCar.doorCount = 17
        otherCar.wheelCount = 8
        
        let pLot = ParkingLot()
        pLot.name = "upside down"
        pLot.objId = "8675309"
        pLot.cars.append(car)
        pLot.cars.append(otherCar)
        pLot.motorcycles.append(cycle)
                
        let pData = try coder.encode(pLot)
        
        XCTAssertNotNil(pData)
        
        let uString = String(data: pData!, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let jString = String(data: jsonData!, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        try jString?.write(toFile: "/tmp/ref.json", atomically: true, encoding: .utf8)
        try uString?.write(toFile: "/tmp/encoded.json", atomically: true, encoding: .utf8)
        
        XCTAssertEqual(uString, jString)
    }
    
    static var allTests = [
        ("testDecodeParkingLotJson", testDecodeParkingLotJson),
        ("testEncodeParkingLotJson", testEncodeParkingLotJson)
    ]
}
