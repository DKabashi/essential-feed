import XCTest

final class FeedPresenter {
    init(view: Any) {
        
    }
}

final class FeedPresenterTests: XCTestCase {
    
    
    func test_init_doesNotSendMessagesToView() {
        let view = ViewSpy()
        _ = FeedPresenter(view: view)
        
        XCTAssertEqual(view.messages, [], "Expected no view messages")
    }
    
    final class ViewSpy {
        private(set) var messages = [String]()
        
    }
}
