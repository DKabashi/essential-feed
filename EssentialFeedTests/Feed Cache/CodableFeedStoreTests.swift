import XCTest
import EssentialFeed

class CodableFeedStore {
    
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var toLocalFeed: [LocalFeedImage] {
            feed.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
        }
    }
    
    private struct CodableFeedImage: Codable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let url: URL
        
        init(from image: LocalFeedImage) {
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.url = image.url
        }
    }

    // TODO: Learn why it takes path from this directory
    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(component: "image-feed.store")

    func retrieve(completion: @escaping FeedStore.RetriveCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        let decoder = JSONDecoder()
        let decodedCache = try! decoder.decode(Cache.self, from: data)
        completion(.success(decodedCache.toLocalFeed, decodedCache.timestamp))
    }

    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
        let encodedData = try! encoder.encode(cache)
        try! encodedData.write(to: storeURL)
        completion(nil)
    }
}

final class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(component: "image-feed.store")
        
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    override func tearDown() {
        super.tearDown()
        
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(component: "image-feed.store")
        
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        
        let exp = XCTestExpectation(description: "Wait for retrieve to complete")
        sut.retrieve { result in
            switch result {
            case .empty:
                exp.fulfill()
            default:
                XCTFail("Expected empty result but got \(result) instead")
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = CodableFeedStore()
        
        let exp = XCTestExpectation(description: "Wait for the two retrivals to complete")
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    exp.fulfill()
                default:
                    XCTFail("Expected empty result twice from empty cache, but got \(firstResult) and \(secondResult) instead")
                }
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_returnsInsertedDataAfterSuccessfulInsertion() {
        let sut = CodableFeedStore()
        let feed = [uniqueLocalFeedItem()]
        let timestamp = Date()
        let exp = XCTestExpectation(description: "Wait for retrieve and insertion to complete")
        
        sut.insert(feed, timestamp: timestamp) { insertionResult in
            XCTAssertNil(insertionResult, "Expected insertion to be successful")
            
            sut.retrieve { retrivalResult in
                switch retrivalResult {
                case .success(let recievedLocalItems, let receivedTimestamp):
                    XCTAssertEqual(receivedTimestamp, timestamp)
                    XCTAssertEqual(recievedLocalItems, feed)
                default:
                    XCTFail("Expected success result with timestamp \(timestamp), and feed \(feed), but got \(retrivalResult) instead")
                }
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
