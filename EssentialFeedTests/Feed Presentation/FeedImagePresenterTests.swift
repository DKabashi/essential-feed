import XCTest

struct FeedLoadingImageViewModel {
    let isLoading: Bool
}

protocol FeedLoadingImageView {
    func display(_ model: FeedLoadingImageViewModel)
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
    
    init(imageView: View, loadingView: FeedLoadingImageView) {
        self.imageView = imageView
        self.loadingView = loadingView
    }
    
    func didStartLoadingImage(_ model: FeedImageViewModel<Image>) {
        imageView.display(FeedImageViewModel(image: nil, location: model.location, description: model.description))
        loadingView.display(FeedLoadingImageViewModel(isLoading: true))
    }
}

final class FeedImagePresenterTests: XCTestCase {
    
    func test_init_displaysNoMessage() {
        let (_, view) = makeSUT()
        
        XCTAssertEqual(view.messages, [])
    }
    
    func test_didStartLoadingImage_displaysInitialFeedImageDataAndLoader() {
        let (sut, view) = makeSUT()
        
        let model = FeedImageViewModel<ImageSpy>(image: nil, location: "Loc", description: "Desc")
        sut.didStartLoadingImage(model)
        
        XCTAssertEqual(view.messages, [
            .display(image: model.image, location: model.location, description: model.description),
            .display(isLoading: true)
        ])
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, ImageSpy>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(imageView: view, loadingView: view)
        checkForMemoryLeaks(for: view, file: file, line: line)
        checkForMemoryLeaks(for: sut, file: file, line: line)
        return (sut, view)
    }
    
    final class ViewSpy: FeedLoadingImageView, FeedImageView {
        enum Message: Equatable {
            case display(isLoading: Bool)
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
    }
    
    enum ImageSpy: Equatable {}
}
