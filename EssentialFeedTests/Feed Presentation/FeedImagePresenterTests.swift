import XCTest

struct FeedImageViewModel {
    let isLoading: Bool
}

protocol FeedImageView {
    func display(_ model: FeedImageViewModel)
}

final class FeedImagePresenter {
    private let view: FeedImageView
    
    init(view: FeedImageView) {
        self.view = view
    }
    
    func didStartLoadingImage() {
        view.display(FeedImageViewModel(isLoading: true))
    }
}

final class FeedImagePresenterTests: XCTestCase {
    
    func test_init_displaysNoMessage() {
        let view = ViewSpy()
        _ = FeedImagePresenter(view: view)
        
        XCTAssertEqual(view.messages, [])
    }
    
    func test_didStartLoadingImage_displaysLoader() {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        
        sut.didStartLoadingImage()
        XCTAssertEqual(view.messages, [.display(isLoading: true)])
    }
    
    final class ViewSpy: FeedImageView {
        enum Message: Equatable {
            case display(isLoading: Bool)
        }
        
        private(set) var messages = [Message]()
        
        func display(_ model: FeedImageViewModel) {
            messages.append(.display(isLoading: model.isLoading))
        }
    }
}
