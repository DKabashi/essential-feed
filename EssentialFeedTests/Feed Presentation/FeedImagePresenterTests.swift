import XCTest
import EssentialFeed

final class FeedImagePresenterTests: XCTestCase {
    
    func test_init_displaysNoMessage() {
        let (_, view) = makeSUT()
        
        XCTAssertEqual(view.messages, [])
    }
    
    func test_didStartLoadingImage_displaysInitialFeedImageDataAndHidesRetryButtonAndShowsLoader() {
        let (sut, view) = makeSUT()
        let model = uniqueFeedItem()
        
        sut.didStartLoadingImage(model: model)
        
        XCTAssertEqual(view.messages, [
            .display(image: nil, location: model.location, description: model.description),
            .display(shouldRetry: false),
            .display(isLoading: true)
        ])
    }
    
    func test_didFinishLoadingImageWithError_hidesLoaderAndShowsRetryButton() {
        let (sut, view) = makeSUT()
        
        sut.didFinishLoadingImageWithError(anyNSError())
        
        XCTAssertEqual(view.messages, [
            .display(isLoading: false),
            .display(shouldRetry: true)
        ])
    }
    
    func test_didFinishLoadingImage_hidesLoaderAndShowsRetryButtonOnInvalidData() {
        let (sut, view) = makeSUT()
        let invalidData = Data("".utf8)
        let model = uniqueFeedItem()
        
        sut.didFinishLoadingImage(with: invalidData, model: model)
        
        XCTAssertEqual(view.messages, [
            .display(isLoading: false),
            .display(shouldRetry: true)
        ])
    }
    
    func test_didFinishLoadingImage_displaysImageAndHidesRetryButtonAndLoader() {
        let (sut, view) = makeSUT()
        let validData = Data("valid data".utf8)
        let model = uniqueFeedItem()
        
        sut.didFinishLoadingImage(with: validData, model: model)
        
        XCTAssertEqual(view.messages, [
            .display(isLoading: false),
            .display(shouldRetry: false),
            .display(image: ImageSpy.someValue, location: model.location, description: model.description)
        ])
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, ImageSpy>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(imageView: view, loadingView: view, retryView: view, imageTransformer: { data in
            if data.isEmpty {
                return nil
            } else {
                return ImageSpy.someValue
            }
        })
        checkForMemoryLeaks(for: view, file: file, line: line)
        checkForMemoryLeaks(for: sut, file: file, line: line)
        return (sut, view)
    }
    
    final class ViewSpy: LoadingView, FeedImageView, RetryView {
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
        
        func display(_ model: LoadingViewModel) {
            messages.append(.display(isLoading: model.isLoading))
        }
        
        func display(_ model: FeedImageViewModel<ImageSpy>) {
            messages.append(.display(image: model.image, location: model.location, description: model.description))
        }
        
        func display(_ model: RetryViewModel) {
            messages.append(.display(shouldRetry: model.shouldRetry))
        }
    }
    
    enum ImageSpy: Equatable {
        case someValue
    }
}
