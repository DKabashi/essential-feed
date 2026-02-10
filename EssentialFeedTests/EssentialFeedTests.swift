//
//  EssentialFeedTests.swift
//  EssentialFeedTests
//
//  Created by Donat Kabashi on 2/10/26.
//

import XCTest
@testable import EssentialFeed

class RemoteFeedLoader: FeedLoader {
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func loadFeed(completion: @escaping (LoadFeedResult) -> Void) {
        
    }
}

final class EssentialFeedTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_init_urlIsNotNil() {
        let sut = RemoteFeedLoader(url: URL(string: "https://google.com")!)
        
        XCTAssertNotNil(sut.url)
    }

}
