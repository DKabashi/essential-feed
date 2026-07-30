import XCTest


// TODO: Refactor to use the laodingview
struct FeedLoadingImageViewModel {
    let isLoading: Bool
}

protocol FeedLoadingImageView {
    func display(_ model: FeedLoadingImageViewModel)
}

struct RetryViewModel {
    let shouldRetry: Bool
}

protocol RetryView {
    func display(_ model: RetryViewModel)
}

struct FeedImageViewModel<Image> {
    let image: Image?
    let location: String?
    let description: String?
    
    var hasLocation: Bool {
        return location != nil
    }
}

protocol FeedImageView {
    associatedtype Image

    func display(_ model: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let imageView: View
    private let loadingView: FeedLoadingImageView
    private let retryView: RetryView
    
    init(imageView: View, loadingView: FeedLoadingImageView, retryView: RetryView) {
        self.imageView = imageView
        self.loadingView = loadingView
        self.retryView = retryView
    }
    
    func didStartLoadingImage(_ model: FeedImageViewModel<Image>) {
        imageView.display(FeedImageViewModel(image: nil, location: model.location, description: model.description))
        retryView.display(RetryViewModel(shouldRetry: false))
        loadingView.display(FeedLoadingImageViewModel(isLoading: true))
    }
}

final class FeedImagePresenterTests: XCTestCase {
    
    func test_init_displaysNoMessage() {
        let (_, view) = makeSUT()
        
        XCTAssertEqual(view.messages, [])
    }
    
    func test_didStartLoadingImage_displaysInitialFeedImageDataAndNoRetryButtonAndLoader() {
        let (sut, view) = makeSUT()
        
        let model = FeedImageViewModel<ImageSpy>(image: nil, location: "Loc", description: "Desc")
        sut.didStartLoadingImage(model)
        
        XCTAssertEqual(view.messages, [
            .display(image: model.image, location: model.location, description: model.description),
            .display(shouldRetry: false),
            .display(isLoading: true)
        ])
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, ImageSpy>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(imageView: view, loadingView: view, retryView: view)
        checkForMemoryLeaks(for: view, file: file, line: line)
        checkForMemoryLeaks(for: sut, file: file, line: line)
        return (sut, view)
    }
    
    final class ViewSpy: FeedLoadingImageView, FeedImageView, RetryView {
        enum Message: Equatable {
            case display(isLoading: Bool)
            case display(shouldRetry: Bool)
            case display(
                image: ImageSpy?,
                location: String?,
                description: String?
            )
        }
        
        private(set) var messages = [Message]()
        
        func display(_ model: FeedLoadingImageViewModel) {
            messages.append(.display(isLoading: model.isLoading))
        }
        
        func display(_ model: FeedImageViewModel<ImageSpy>) {
            messages.append(.display(image: model.image, location: model.location, description: model.description))
        }
        
        func display(_ model: RetryViewModel) {
            messages.append(.display(shouldRetry: model.shouldRetry))
        }
    }
    
    enum ImageSpy: Equatable {}
}
