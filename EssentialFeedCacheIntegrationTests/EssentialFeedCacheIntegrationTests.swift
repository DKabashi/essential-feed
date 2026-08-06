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
        let sut = makeFeedLoader()
        
        expect(sut, toLoad: [])
    }
    
    func test_load_deliversInsertedItemsOnNonEmptyCache() {
        let sutToInsert = makeFeedLoader()
        let sutToLoad = makeFeedLoader()
        let items = [uniqueFeedItem()]
        
        save(items, with: sutToInsert)
        
        expect(sutToLoad, toLoad: items)
    }
    
    func test_save_overridesItemsSavedOnASeparateInstance() {
        let sutToInsertFirstItems = makeFeedLoader()
        let sutToInsertLatestItems = makeFeedLoader()
        let sutToLoadLatestItems = makeFeedLoader()
        
        save([uniqueFeedItem()], with: sutToInsertFirstItems)
        
        let latestItems = [uniqueFeedItem(), uniqueFeedItem()]
        save(latestItems, with: sutToInsertLatestItems)
        
        expect(sutToLoadLatestItems, toLoad: latestItems)
    }
    
    func test_loadImageData_deliversSavedDataOnASeparateInstance() {
        let imageLoaderToPerformSave = makeImageLoader()
        let imageLoaderToPerformLoad = makeImageLoader()
        let feedLoader = makeFeedLoader()
        let image = uniqueFeedItem()
        let dataToSave = anyData()
        
        save([image], with: feedLoader)
        save(dataToSave, for: image.url, with: imageLoaderToPerformSave)
        
        expect(imageLoaderToPerformLoad, toLoad: dataToSave, for: image.url)
    }
    
    // MARK: - Helpers
    
    private func makeFeedLoader(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedLoader(store: store, createTimestamp: Date.init)
        checkForMemoryLeaks(for: sut, file: file, line: line)
        checkForMemoryLeaks(for: store, file: file, line: line)
        return sut
    }
    
    private func makeImageLoader(file: StaticString = #file, line: UInt = #line) -> LocalFeedImageDataLoader {
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedImageDataLoader(store: store)
        checkForMemoryLeaks(for: store, file: file, line: line)
        checkForMemoryLeaks(for: sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: LocalFeedLoader, toLoad expectedItems: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load to finish")
        sut.loadFeed { receivedResult in
            switch receivedResult {
            case .success(let recievedItems):
                XCTAssertEqual(recievedItems, expectedItems)
            default:
                XCTFail("Expected items: \(expectedItems), but got a different result: \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3.0)
    }
    
    private func save(_ feed: [FeedImage], with loader: LocalFeedLoader, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for insertion to finish")
        loader.save(feed: feed) { result in
            if case let Result.failure(error) = result {
                XCTFail("Expected to save feed successfully, got error: \(error)", file: file, line: line)
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3.0)
    }
    
    private func save(_ data: Data, for url: URL, with loader: LocalFeedImageDataLoader, file: StaticString = #file, line: UInt = #line) {
        let saveExp = expectation(description: "Wait for save completion")
        loader.save(data, for: url) { result in
            if case let Result.failure(error) = result {
                XCTFail("Expected to save image data successfully, got error: \(error)", file: file, line: line)
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toLoad expectedData: Data, for url: URL, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        _ = sut.loadImageData(from: url) { result in
            switch result {
            case let .success(loadedData):
                XCTAssertEqual(loadedData, expectedData, file: file, line: line)
                
            case let .failure(error):
                XCTFail("Expected successful image data result, got \(error) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
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
