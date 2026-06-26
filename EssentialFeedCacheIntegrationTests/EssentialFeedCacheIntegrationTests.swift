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
        
        let exp = expectation(description: "Wait for load to finish")
        sut.loadFeed { result in
            switch result {
            case .success(let items):
                XCTAssertTrue(items.isEmpty)
            default:
                XCTFail("Expected empty response but got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3.0)
    }
    
    func test_load_deliversInsertedItemsOnNonEmptyCache() {
        let sutToInsert = makeSUT()
        let sutToDelete = makeSUT()
        let items = [uniqueFeedItem()]
        
        let exp1 = expectation(description: "Wait for insertion to finish")
        sutToInsert.save(feed: items) { insertionError in
            XCTAssertNil(insertionError)
            exp1.fulfill()
        }
        wait(for: [exp1], timeout: 3.0)
        
        let exp2 = expectation(description: "Wait for load to finish")
        sutToDelete.loadFeed { result in
            switch result {
            case .success(let receivedItems):
                XCTAssertEqual(receivedItems, items)
            default:
                XCTFail("Expected items: \(items), but got \(result) instead")
            }
            exp2.fulfill()
        }
        
        wait(for: [exp2], timeout: 3.0)
    }
    
    private func makeSUT() -> LocalFeedLoader {
        let bundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: bundle)
        let sut = LocalFeedLoader(store: store, createTimestamp: Date.init)
        checkForMemoryLeaks(for: sut)
        checkForMemoryLeaks(for: store)
        return sut
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
