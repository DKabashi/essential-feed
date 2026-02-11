//
//  EssentialFeedTests.swift
//  EssentialFeedTests
//
//  Created by Donat Kabashi on 2/10/26.
//

import XCTest
@testable import EssentialFeed



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
    
    private func prepareSUT(url: URL = URL(string: "https://google.com")!) -> (sut: FeedLoader, client: NetworkClientSpy) {
        let client = NetworkClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut: sut, client: client)
    }
    
    private class NetworkClientSpy: NetworkClient {
        var urls: [URL] = []
        func get(url: URL) {
            self.urls.append(url)
        }
    }

}
