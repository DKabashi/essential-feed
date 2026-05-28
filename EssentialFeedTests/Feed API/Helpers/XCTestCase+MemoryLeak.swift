import XCTest

extension XCTestCase {
    func checkForMemoryLeaks(for object: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(object, "Potential Memory Leak", file: file, line: line)
        }
    }
}
