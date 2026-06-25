import XCTest
import EssentialFeed

final class CodableFeedStoreTests: XCTestCase, FailableFeedStoreTestSpecs {
    
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
    
    func test_retrieve_deliversCachedDataOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = [uniqueLocalFeedItem()]
        let timestamp = Date()
        
        insert((feed: feed, timestamp: timestamp), to: sut)
        
        expect(sut, toRetriveWithResult: .success(feed, timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCacheRetrival() {
        let sut = makeSUT()
        let feed = [uniqueLocalFeedItem()]
        let timestamp = Date()
        
        insert((feed: feed, timestamp: timestamp), to: sut)
        
        expect(sut, toRetriveWithResult: .success(feed, timestamp))
        expect(sut, toRetriveWithResult: .success(feed, timestamp))
    }
    
    func test_retrieve_deliversFailureOnRetrivalError() {
        let sut = makeSUT()
        
        try! "Error insertion".write(to: testSpecificStoreURL(), atomically: false, encoding: .utf8)
        
        expect(sut, toRetriveWithResult: .failure(anyNSError()))
    }
    
    func test_retrieve_hasNoSideEffectsOnFailedRetrival() {
        let sut = makeSUT()
        
        try! "Error insertion".write(to: testSpecificStoreURL(), atomically: false, encoding: .utf8)
        
        expect(sut, toRetriveWithResult: .failure(anyNSError()))
        expect(sut, toRetriveWithResult: .failure(anyNSError()))
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        let firstInsertionFeed = [uniqueLocalFeedItem()]
        let firstInsertionTimestamp = Date()
        
        let insertionError = insert((feed: firstInsertionFeed, timestamp: firstInsertionTimestamp), to: sut)
        XCTAssertNil(insertionError, "Expected insertion to be successful")
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        let latestInsertionFeed = [uniqueLocalFeedItem()]
        let latestInsertionTimestamp = Date()
        
        insert((feed: [uniqueLocalFeedItem()], timestamp: Date()), to: sut)
        
        let insertionError = insert((feed: latestInsertionFeed, timestamp: latestInsertionTimestamp), to: sut)
        XCTAssertNil(insertionError, "Expected insertion to be successful")
    }
    
    func test_insert_overridesPreviouslyInsertedValues() {
        let sut = makeSUT()
        let latestInsertionFeed = [uniqueLocalFeedItem(), uniqueLocalFeedItem()]
        let latestInsertionTimestamp = Date().addSeconds(5)
        
        insert((feed: [uniqueLocalFeedItem()], timestamp: Date()), to: sut)
        insert((feed: latestInsertionFeed, timestamp: latestInsertionTimestamp), to: sut)
        
        expect(sut, toRetriveWithResult: .success(latestInsertionFeed, latestInsertionTimestamp))
    }
    
    func test_insert_deliversErrorOnFailedInsertion() {
        let invalidStoreURL = URL(string: "invalidStore://invalid")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        
        let insertionError = insert((feed: [uniqueLocalFeedItem()], timestamp: Date()), to: sut)
        XCTAssertNotNil(insertionError)
    }
    
    func test_insert_hasNoSideEffectsOnFaliedInsertion() {
        let invalidStoreURL = URL(string: "invalidStore://invalid")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        
        insert((feed: [uniqueLocalFeedItem()], timestamp: Date()), to: sut)
        
        expect(sut, toRetriveWithResult: .empty)
    }
    
    func test_deleteCachedFeed_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = deleteCachedFeed(sut)
        XCTAssertNil(deletionError)
    }
    
    func test_deleteCachedFeed_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        deleteCachedFeed(sut)
        
        expect(sut, toRetriveWithResult: .empty)
    }
    
    func test_deleteCachedFeed_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        
        insert((feed: [uniqueLocalFeedItem()], timestamp: Date()), to: sut)
        let deletionError = deleteCachedFeed(sut)
        
        XCTAssertNil(deletionError)
    }
    
    func test_deleteCachedFeed_emptiesThePreviouslyInsertedCache() {
        let sut = makeSUT()
        
        insert((feed: [uniqueLocalFeedItem()], timestamp: Date()), to: sut)
        deleteCachedFeed(sut)

        expect(sut, toRetriveWithResult: .empty)
    }
    
    func test_deleteCachedFeed_deliversErrorOnFailedDeletion() {
        let undeletableFileURL = cachesDirectory()
        let sut = makeSUT(storeURL: undeletableFileURL)
        
        insert((feed: [uniqueLocalFeedItem()], timestamp: Date()), to: sut)
        
        let deletionError = deleteCachedFeed(sut)
        XCTAssertNotNil(deletionError)
    }
    
    func test_deleteCachedFeed_hasNoSideEffectOnFaliedDeletion() {
        let undeletableFileURL = cachesDirectory()
        let sut = makeSUT(storeURL: undeletableFileURL)
        
        deleteCachedFeed(sut)
        
        expect(sut, toRetriveWithResult: .empty)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        
        var expectationOrder = [XCTestExpectation]()
        
        let operation1 = expectation(description: "Expect insertion to complete")
        sut.insert([uniqueLocalFeedItem()], timestamp: Date()) { _ in
            expectationOrder.append(operation1)
            operation1.fulfill()
        }
        
        let operation2 = expectation(description: "Expect deletion to complete")
        sut.deleteCachedFeed { _ in
            expectationOrder.append(operation2)
            operation2.fulfill()
        }
        
        let operation3 = expectation(description: "Expect insertion to complete")
        sut.insert([uniqueLocalFeedItem()], timestamp: Date()) { _ in
            expectationOrder.append(operation3)
            operation3.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
        
        XCTAssertEqual(expectationOrder, [operation1, operation2, operation3])
    }
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        checkForMemoryLeaks(for: sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: FeedStore, toRetriveWithResult expectedResult: RetrieveResult, file: StaticString = #filePath, line: UInt = #line) {
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
    private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> NSError? {
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
    private func deleteCachedFeed(_ sut: FeedStore) -> NSError? {
        let exp = XCTestExpectation(description: "Wait for cache to be deleted")
        var recivedError: NSError?
        sut.deleteCachedFeed { deletionError in
            recivedError = deletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return recivedError
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
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
