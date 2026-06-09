import EssentialFeed
import XCTest

final class EssentialFeedAPIEndToEndTests: XCTestCase {

    func test_endToEndServerGetFeedResult_returnsExpectedTestItemsData() {
        let feedLoader = getFeedLoader()
        
        let capturedResult = getFeedResult(with: feedLoader)
      
        switch capturedResult {
        case .success(let items):
            XCTAssertEqual(
                items.count,
                8,
                "Expected 8 items but got \(items.count) instead"
            )
            XCTAssertEqual(expectedItem(at: 0), items[0])
            XCTAssertEqual(expectedItem(at: 1), items[1])
            XCTAssertEqual(expectedItem(at: 2), items[2])
            XCTAssertEqual(expectedItem(at: 3), items[3])
            XCTAssertEqual(expectedItem(at: 4), items[4])
            XCTAssertEqual(expectedItem(at: 5), items[5])
            XCTAssertEqual(expectedItem(at: 6), items[6])
            XCTAssertEqual(expectedItem(at: 7), items[7])
        case .failure(let err):
            XCTFail("Expected success, but got error instead: \(err)")
        default:
            XCTFail("Expected success, but got nothing instead")
        }
    }
    
    // MARK: - Helpers
    
    private func getFeedLoader(file: StaticString = #filePath, line: UInt = #line) -> FeedLoader {
        let client = URLSessionHTTPClient()
        let feedLoader = RemoteFeedLoader(url: serverURL(), client: client)
        
        checkForMemoryLeaks(for: client, file: file, line: line)
        checkForMemoryLeaks(for: feedLoader, file: file, line: line)
        
        return feedLoader
    }
    
    private func getFeedResult(with feedLoader: FeedLoader) -> LoadFeedResult? {
        let expectation = XCTestExpectation(
            description: "Expect the remote feed loader to load items"
        )
        var capturedResult: LoadFeedResult?
        
        feedLoader.loadFeed { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        return capturedResult
    }
    
    private func serverURL() -> URL {
        return URL(
            string:
                "https://essentialdeveloper.com/feed-case-study/test-api/feed"
        )!
    }


    private func expectedItem(at index: Int) -> FeedItem {
        return FeedItem(
            id: id(at: index),
            description: description(at: index),
            location: location(at: index),
            imageURL: imageURL(at: index)
        )
    }

    private func id(at index: Int) -> UUID {
        return UUID(
            uuidString: [
                "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
                "BA298A85-6275-48D3-8315-9C8F7C1CD109",
                "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
                "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
                "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
                "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
                "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
                "F79BD7F8-063F-46E2-8147-A67635C3BB01",
            ][index]
        )!
    }

    private func description(at index: Int) -> String? {
        return [
            "Description 1",
            nil,
            "Description 3",
            nil,
            "Description 5",
            "Description 6",
            "Description 7",
            "Description 8",
        ][index]
    }
    
    private func location(at index: Int) -> String? {
        return [
            "Location 1",
            "Location 2",
            nil,
            nil,
            "Location 5",
            "Location 6",
            "Location 7",
            "Location 8",
        ][index]
    }
    
    private func imageURL(at index: Int) -> URL {
        return URL(string: "https://url-\(index+1).com")!
    }
}
