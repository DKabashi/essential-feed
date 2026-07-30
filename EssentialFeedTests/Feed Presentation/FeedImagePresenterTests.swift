import XCTest

final class FeedImagePresenter {
    
}

final class FeedImagePresenterTests: XCTest {
    
    func test_init_displaysNoMessage() {
        let view = ViewSpy()
        _ = FeedImagePresenter()
        
        XCTAssertEqual(view.messages, [])
    }
    
    
    final class ViewSpy {
        private(set) var messages = [String]()
        
    }
}
