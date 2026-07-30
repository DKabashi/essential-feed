import XCTest
import EssentialFeed


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
    private let imageTransformer: (Data) -> Image?
    
    init(imageView: View, loadingView: FeedLoadingImageView, retryView: RetryView, imageTransformer: @escaping (Data) -> Image?) {
        self.imageView = imageView
        self.loadingView = loadingView
        self.retryView = retryView
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImage(model: FeedImage) {
        imageView.display(FeedImageViewModel(image: nil, location: model.location, description: model.description))
        retryView.display(RetryViewModel(shouldRetry: false))
        loadingView.display(FeedLoadingImageViewModel(isLoading: true))
    }
    
    private struct ImageDataTransformationError: Error {}

    func didFinishLoadingImage(with data: Data, model: FeedImage) {
        guard let image = imageTransformer(data) else {
            didFinishLoadingImageWithError(ImageDataTransformationError())
            return
        }
        loadingView.display(FeedLoadingImageViewModel(isLoading: false))
        retryView.display(RetryViewModel(shouldRetry: false))
        imageView.display(
            FeedImageViewModel(
                image: image,
                location: model.location,
                description: model.description
            )
        )
    }
    
    
    func didFinishLoadingImageWithError(_ error: Error) {
        loadingView.display(FeedLoadingImageViewModel(isLoading: false))
        retryView.display(RetryViewModel(shouldRetry: true))
    }
}

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
    
    enum ImageSpy: Equatable {
        case someValue
    }
}
