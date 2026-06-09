import XCTest
import EssentialFeed

final class EssentialFeedAPIEndToEndTests: XCTestCase {

    func test_endToEndServerGetFeedAPI_returnsExpectedTestData() {
        let serverURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient()
        let feedLoader = RemoteFeedLoader(url: serverURL, client: client)
        
        
        let expectation = XCTestExpectation(description: "Expect the remote feed loader to load items")
        feedLoader.loadFeed { result in
            switch result {
            case .success(let items):
                XCTAssertEqual(items.count, 8, "Expected 8 items but got \(items.count) instead")
            case .failure(let err):
                XCTFail("Expected success, but got error instead: \(err)")
            default:
                XCTFail("Expected success, but got something else instead")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
}
