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

    private var storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }

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
        
        createNewStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        cleanStoreState()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetriveWithResult: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetriveWithResult: .empty)
        expect(sut, toRetriveWithResult: .empty)
    }
    
    func test_retrieve_returnsInsertedDataAfterSuccessfulInsertion() {
        let sut = makeSUT()
        let feed = [uniqueLocalFeedItem()]
        let timestamp = Date()
        let exp = XCTestExpectation(description: "Wait for retrieve and insertion to complete")
        
        sut.insert(feed, timestamp: timestamp) { insertionResult in
            XCTAssertNil(insertionResult, "Expected insertion to be successful")
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        expect(sut, toRetriveWithResult: .success(feed, timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCacheRetrival() {
        let sut = makeSUT()
        let feed = [uniqueLocalFeedItem()]
        let timestamp = Date()
        
        let exp = XCTestExpectation(description: "Wait for insertion to complete")
        sut.insert(feed, timestamp: timestamp) { insertionResult in
            XCTAssertNil(insertionResult, "Expected insertion to be successful")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        expect(sut, toRetriveWithResult: .success(feed, timestamp))
        expect(sut, toRetriveWithResult: .success(feed, timestamp))
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: testSpecificStoreURL())
        checkForMemoryLeaks(for: sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: CodableFeedStore, toRetriveWithResult expectedResult: RetrieveResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = XCTestExpectation(description: "Wait for retrieve to complete")
        
        sut.retrieve { retrivalResult in
            switch (retrivalResult, expectedResult) {
            case (
                let .success(recievedLocalItems, receivedTimestamp),
                let .success(expectedLocalItems, expectedTimestamp)
            ):
                XCTAssertEqual(receivedTimestamp, expectedTimestamp)
                XCTAssertEqual(recievedLocalItems, expectedLocalItems)
            case (.empty, .empty):
                break
            default:
                XCTFail("Expected retrive to complete with \(expectedResult), but got \(retrivalResult) result instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func testSpecificStoreURL() -> URL {
        // TODO: Learn why it takes path from this directory
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appending(component: "\(type(of: self)).store")
    }
    
    private func createNewStoreState() {
        removeStoreArtifact()
    }
    
    private func cleanStoreState() {
        removeStoreArtifact()
    }
    
    private func removeStoreArtifact() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
