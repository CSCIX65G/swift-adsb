import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ParsingTests.allTests),
        testCase(APITests.allTests),
    ]
}
#endif
