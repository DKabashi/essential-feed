import XCTest

struct FeedLoadingImageViewModel {
    let isLoading: Bool
}

protocol FeedLoadingImageView {
    func display(_ model: FeedLoadingImageViewModel)
}

final class FeedImagePresenter {
    private let view: FeedLoadingImageView
    
    init(view: FeedLoadingImageView) {
        self.view = view
    }
    
    func didStartLoadingImage() {
        view.display(FeedLoadingImageViewModel(isLoading: true))
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
    
    final class ViewSpy: FeedLoadingImageView {
        enum Message: Equatable {
            case display(isLoading: Bool)
        }
        
        private(set) var messages = [Message]()
        
        func display(_ model: FeedLoadingImageViewModel) {
            messages.append(.display(isLoading: model.isLoading))
        }
    }
}
