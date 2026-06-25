import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    func expect(_ sut: FeedStore, toRetriveWithResult expectedResult: RetrieveResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = XCTestExpectation(description: "Wait for retrieve to complete")
        
        sut.retrieve { retrivalResult in
            switch (retrivalResult, expectedResult) {
            case (.empty, .empty), (.failure, .failure):
                break
            case (
                let .success(recievedLocalItems, receivedTimestamp),
                let .success(expectedLocalItems, expectedTimestamp)
            ):
                XCTAssertEqual(receivedTimestamp, expectedTimestamp)
                XCTAssertEqual(recievedLocalItems, expectedLocalItems)
            default:
                XCTFail("Expected retrive to complete with \(expectedResult), but got \(retrivalResult) result instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> NSError? {
        let exp = XCTestExpectation(description: "Wait for insertion to complete")
        var receivedError: NSError?
        sut.insert(cache.feed, timestamp: cache.timestamp) { insertionResult in
            receivedError = insertionResult
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    @discardableResult
    func deleteCachedFeed(_ sut: FeedStore) -> NSError? {
        let exp = XCTestExpectation(description: "Wait for cache to be deleted")
        var recivedError: NSError?
        sut.deleteCachedFeed { deletionError in
            recivedError = deletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return recivedError
    }
}

