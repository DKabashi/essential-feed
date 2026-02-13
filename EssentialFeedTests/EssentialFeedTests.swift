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
        
        var capturedErrors: [RemoteFeedLoader.Error?] = []
        sut.loadFeed { result in
            switch result {
            case .failure(let error):
                capturedErrors.append(error as? RemoteFeedLoader.Error)
            default: return
            }
        }
        client.completions.first!(.failure(RemoteFeedLoader.Error.connectivity))
        
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_loadFeed_returnsErrorOnClientStatusCodeNon200() {
        let (sut, client) = prepareSUT()
        
    
        let statusCodesToTest = [203, 401, 404, 500, 501]
        
        statusCodesToTest.enumerated().forEach { index, statusCode in
            var capturedErrors: [RemoteFeedLoader.Error?] = []
            sut.loadFeed { result in
                switch result {
                case .failure(let error):
                    capturedErrors.append(error as? RemoteFeedLoader.Error)
                default: return
                }
            }
            
            let urlResponse = HTTPURLResponse(url: client.urls.first!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            let data = Data()
            client.completions[index](.success((data, urlResponse)))
            
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
    }
    
    func test_loadFeed_returnsErrorOn200ResponseAndInvalidJSON() {
        let (sut, client) = prepareSUT()
        
        var capturedErrors: [RemoteFeedLoader.Error?] = []
        sut.loadFeed { result in
            switch result {
            case .failure(let error):
                capturedErrors.append(error as? RemoteFeedLoader.Error)
            default: return
            }
        }
        
        let urlResponse = HTTPURLResponse(url: client.urls.first!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let data = Data()
        client.completions[0](.success((data, urlResponse)))
        
        XCTAssertEqual(capturedErrors, [.invalidData])
    }
    
    // TODO: See why we need to refactor above
    
    private func prepareSUT(url: URL = URL(string: "https://google.com")!) -> (sut: FeedLoader, client: NetworkClientSpy) {
        let client = NetworkClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut: sut, client: client)
    }
    
    private class NetworkClientSpy: NetworkClient {
        private(set) var urls: [URL] = []
        private(set) var completions: [(RemoteFeedLoaderResult) -> Void] = []
        
        func get(url: URL, completion: @escaping (RemoteFeedLoaderResult) -> Void) {
            self.urls.append(url)
            completions.append(completion)
        }
    }

}
