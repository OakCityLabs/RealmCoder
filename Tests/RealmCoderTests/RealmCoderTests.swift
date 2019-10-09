import XCTest
@testable import RealmCoder

final class RealmCoderTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(RealmCoder().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
