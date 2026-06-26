import XCTest
import EssentialFeed

final class EssentialFeedCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    func test_load_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toLoad: .success([]))
    }
    
    func test_load_deliversInsertedItemsOnNonEmptyCache() {
        let sutToInsert = makeSUT()
        let sutToLoad = makeSUT()
        let items = [uniqueFeedItem()]
        
        let exp1 = expectation(description: "Wait for insertion to finish")
        sutToInsert.save(feed: items) { insertionError in
            XCTAssertNil(insertionError)
            exp1.fulfill()
        }
        wait(for: [exp1], timeout: 3.0)
        
        expect(sutToLoad, toLoad: .success(items))
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let bundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: bundle)
        let sut = LocalFeedLoader(store: store, createTimestamp: Date.init)
        checkForMemoryLeaks(for: sut, file: file, line: line)
        checkForMemoryLeaks(for: store, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: LocalFeedLoader, toLoad expectedResult: LocalFeedLoader.LoadResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load to finish")
        sut.loadFeed { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success(let recievedItems), .success(let expectedItems)):
                XCTAssertEqual(recievedItems, expectedItems)
            default:
                XCTFail("Expected result: \(expectedResult), but got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3.0)
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifact()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifact()
    }
    
    private func deleteStoreArtifact() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
