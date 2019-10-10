//
//  XCTestManifests.swift
//  RealmCoderTests
//
//  Created by Jay Lyerly on 10/9/19.
//  Copyright © 2019 Oak City Labs. All rights reserved.
//

import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(RealmCoderTests.allTests),
        testCase(UserTests.allTests),
        testCase(EnvelopedUserTests.allTests),
        testCase(MuppetTests.allTests),
        testCase(ParkingLotTests.allTests),
        testCase(FarmTests.allTests)
    ]
}
#endif
