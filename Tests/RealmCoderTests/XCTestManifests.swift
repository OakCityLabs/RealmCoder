import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(RealmCoderTests.allTests),
        testCase(UserTests.allTests),
    ]
}
#endif
