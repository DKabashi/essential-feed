//
//  EssentialFeedTests.swift
//  EssentialFeedTests
//
//  Created by Donat Kabashi on 2/10/26.
//

import XCTest
import EssentialFeed

final class EssentialFeedTests: XCTestCase {

    func test_init_urlIsNotNil() {
        let (_, client) = prepareSUT()
        
        XCTAssertTrue(client.urls.isEmpty)
    }
    
    func test_loadFeed_assignsUrlToClient() {
        let (sut, client) = prepareSUT()
        
        sut.loadFeed { _ in }
        
        XCTAssertFalse(client.urls.isEmpty)
    }
    
    func test_loadFeed_calledTwiceAssignsSameNumberOfUrlsToClient() {
        let (sut, client) = prepareSUT()
        
        sut.loadFeed { _ in }
        sut.loadFeed { _ in }
        
        XCTAssertEqual(client.urls.count, 2)
    }
    
    func test_loadFeed_returnsErrorOnClientError() {
        let (sut, client) = prepareSUT()
        
        let expectedResult: LoadFeedResult = .failure(RemoteFeedLoader.Error.connectivity)
        expect(sut, toCompleteWithResult: expectedResult, when: {
            client.completeWithConnectivityError()
        })
    }
    
    func test_loadFeed_returnsErrorOnClientStatusCodeNon200() {
        let (sut, client) = prepareSUT()
        
    
        let statusCodesToTest = [203, 401, 404, 500, 501]
        
        statusCodesToTest.enumerated().forEach { index, statusCode in
            let expectedResult: LoadFeedResult = .failure(RemoteFeedLoader.Error.invalidData)
            expect(sut, toCompleteWithResult: expectedResult, when: {
                client.complete(with: statusCode, at: index)
            })
        }
    }
    
    func test_loadFeed_returnsErrorOn200ResponseAndInvalidJSON() {
        let (sut, client) = prepareSUT()
        
        let expectedResult: LoadFeedResult = .failure(RemoteFeedLoader.Error.invalidData)
        expect(sut, toCompleteWithResult: expectedResult, when: {
            client.complete(with: 200)
        })
    }
    
    
    func test_loadFeed_returnsEmtpyArrayOn200ResponseWithValidEmptyJson() {
        let (sut, client) = prepareSUT()
        
        let expectedResult: LoadFeedResult = .success([])
        expect(sut, toCompleteWithResult: expectedResult, when: {
            let jsonData: Data = "{\"items\": []}".data(using: .utf8)!
            client.complete(with: 200, data: jsonData)
        })
    }
    
    func test_loadFeed_returnsFeedItemsOn200ResponseWithValidJSON() {
        
    }
    
    
    private func prepareSUT(url: URL = URL(string: "https://google.com")!) -> (sut: FeedLoader, client: NetworkClientSpy) {
        let client = NetworkClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut: sut, client: client)
    }
    
    private func expect(
        _ sut: FeedLoader,
        toCompleteWithResult result: LoadFeedResult,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        var capturedErrors: [RemoteFeedLoader.Error?] = []
        var capturedItems: [FeedItem]?
        sut.loadFeed { result in
            switch result {
            case .success(let feedItems):
                capturedItems = feedItems
            case .failure(let error):
                capturedErrors.append(error as? RemoteFeedLoader.Error)
            default: return
            }
        }
        
        action()
        
        switch result {
        case .success(let items):
            XCTAssertEqual(capturedItems, items, file: file, line: line)
        case .failure(let error):
            XCTAssertEqual(capturedErrors, [error as? RemoteFeedLoader.Error], file: file, line: line)
        @unknown default: fatalError()
        }
       
    }
    
    
    private class NetworkClientSpy: NetworkClient {
        private(set) var urls: [URL] = []
        private(set) var completions: [(RemoteFeedLoaderResult) -> Void] = []
        
        func get(url: URL, completion: @escaping (RemoteFeedLoaderResult) -> Void) {
            self.urls.append(url)
            completions.append(completion)
        }
        
        func complete(with statusCode: Int, at index: Int = 0, data: Data = Data()) {
            let urlResponse = HTTPURLResponse(url: urls.first!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            completions[index](.success((data, urlResponse)))
        }
        
        func completeWithConnectivityError() {
            completions.first!(.failure(RemoteFeedLoader.Error.connectivity))
        }
    }

}
