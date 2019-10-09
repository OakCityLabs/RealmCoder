//
//  File.swift
//  
//
//  Created by Jay Lyerly on 10/9/19.
//

import XCTest
@testable import RealmCoder
import RealmSwift

final class BasicUserTests: XCTestCase {
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
    
    func testDecodeUserJson() throws {

        loadJson(fromFile: "user.json")
        
        let user = try coder.decode(User.self, from: jsonData)
        
        XCTAssertEqual(user.firstName, "Barry")
        XCTAssertEqual(user.lastName, "Allen")
        XCTAssertEqual(user.username, "speedy@starlabs.com")
        XCTAssertEqual(user.rank, 4)
        XCTAssertEqual(user.objId, "fec224c1-d529-4af7-8a0f-c591e70d5599")
    }
    
    func testDecodeUserListJson() throws {

        loadJson(fromFile: "user_list.json")
        
        let users = try coder.decodeArray(User.self, from: jsonData)
        
        XCTAssertEqual(users.count, 3)
        
//        XCTAssertEqual(user.firstName, "Barry")
//        XCTAssertEqual(user.lastName, "Allen")
//        XCTAssertEqual(user.username, "speedy@starlabs.com")
//        XCTAssertEqual(user.rank, 4)
//        XCTAssertEqual(user.objId, "fec224c1-d529-4af7-8a0f-c591e70d5599")
    }

    static var allTests = [
        ("testDecodeUserJson", testDecodeUserJson),
        ("testDecodeUserListJson", testDecodeUserListJson),
    ]
}
