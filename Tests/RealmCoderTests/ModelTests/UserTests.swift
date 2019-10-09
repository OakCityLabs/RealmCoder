//
//  UserTests.swift
//  RealmCoderTests
//
//  Created by Jay Lyerly on 10/9/19.
//  Copyright © 2019 Oak City Labs. All rights reserved.
//

@testable import RealmCoder
import RealmSwift
import XCTest

final class UserTests: XCTestCase {
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
        
        XCTAssertEqual(users[0].firstName, "Bruce")
        XCTAssertEqual(users[0].lastName, "Wayne")
        XCTAssertEqual(users[0].username, "bats@waynetech.com")
        XCTAssertEqual(users[0].rank, 1)
        XCTAssertEqual(users[0].objId, "843eb4e2-babf-4fac-86bd-1bce7dc3f7a5")
        
        XCTAssertEqual(users[1].firstName, "Hal")
        XCTAssertEqual(users[1].lastName, "Jordan")
        XCTAssertEqual(users[1].username, "ace@ferrisaviation.com")
        XCTAssertEqual(users[1].rank, 2)
        XCTAssertEqual(users[1].objId, "559165df-c246-4c39-990f-933f89088bb8")
        
        XCTAssertEqual(users[2].firstName, "Clark")
        XCTAssertEqual(users[2].lastName, "Kent")
        XCTAssertEqual(users[2].username, "bluetights@dailyplanet.com")
        XCTAssertEqual(users[2].rank, 3)
        XCTAssertEqual(users[2].objId, "9e96af36-e672-4b9a-a9d8-bc291022e7c3")
    }

    static var allTests = [
        ("testDecodeUserJson", testDecodeUserJson),
        ("testDecodeUserListJson", testDecodeUserListJson),
    ]
}
