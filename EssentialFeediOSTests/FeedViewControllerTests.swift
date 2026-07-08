import XCTest
import EssentialFeed
import EssentialFeediOS

final class FeedViewControllerTests: XCTestCase {

    func test_loadFeedActions_requestFeedLoadInOrder() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expect no feed loading on VC init")
        
        sut.simulateViewAppearance()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expect the feed to load on viewDidLoad")
        
        sut.simulateUserInitiatedFeedLoad()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expect the feed to load again after user initiates a feed load")
        
        sut.simulateUserInitiatedFeedLoad()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expect the feed to load for the third time after another user initiates a feed load")
    }
    
    func test_refreshIndicator_changesVisibilityBasedOnIsFeedLoading() {
        let (sut, loader) = makeSUT()

        sut.simulateViewAppearance()
        XCTAssertTrue(sut.isShowingRefreshIndicator, "Expect loading indicator to show after on viewIsAppearing")

        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingRefreshIndicator, "Expect loading indicator to hide after the feed load is finished")
  
        sut.simulateUserInitiatedFeedLoad()
        XCTAssertTrue(sut.isShowingRefreshIndicator, "Expect loading indicator to show again after on user initiated feed load")
        
        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingRefreshIndicator, "Expect loading indicator to hide after the user initiated feed load is finished with error")
        
        sut.simulateViewAppearance()
        XCTAssertFalse(sut.isShowingRefreshIndicator, "Expect loading indicator to not be visible the rest of the times viewIsAppearing is called")
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedImages() {
        let (sut, loader) = makeSUT()
        let item0 = uniqueFeedImage(description: "Desc", location: "Loc")
        let item1 = uniqueFeedImage(description: nil, location: nil)
        let item2 = uniqueFeedImage(description: "Desc", location: nil)
        let item3 = uniqueFeedImage(description: nil, location: "Loc")
        let itemsList = [item0, item1, item2, item3]

        assertThat(sut, isRendering: [])

        sut.simulateViewAppearance()
        loader.completeFeedLoading(with: [item0], at: 0)
        assertThat(sut, isRendering: [item0])
        
        sut.simulateUserInitiatedFeedLoad()
        loader.completeFeedLoading(with: itemsList, at: 1)
        assertThat(sut, isRendering: itemsList)
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderedStateOnError() {
        let (sut, loader) = makeSUT()
        let item = uniqueFeedImage()
        
        sut.simulateViewAppearance()
        loader.completeFeedLoading(with: [item], at: 0)
        
        sut.simulateUserInitiatedFeedLoad()
        loader.completeFeedLoadingWithError(at: 1)
        
        assertThat(sut, isRendering: [item])
    }
    
    func test_feedImageView_loadsImageURLWhenVisible() {
        let (sut, loader) = makeSUT()
        let item0 = uniqueFeedImage(url: URL(string: "http://some-image.com")!)
        let item1 = uniqueFeedImage(url: URL(string: "http://some-other-image.com")!)
        
        sut.simulateViewAppearance()
        loader.completeFeedLoading(with: [item0, item1], at: 0)
        XCTAssertEqual(loader.loadedImages, [], "Expected no image url request until views become visible")
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImages, [item0.url], "Expected first image url request once the first view becomes visible")
        
        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImages, [item0.url, item1.url], "Expected second image url request once the second view becomes visible")
    }
    
    func test_feedImageView_cancelsImageURLLoadingWhenViewDissapears() {
        let (sut, loader) = makeSUT()
        let item0 = uniqueFeedImage(url: URL(string: "http://some-image.com")!)
        let item1 = uniqueFeedImage(url: URL(string: "http://some-other-image.com")!)
        
        sut.simulateViewAppearance()
        loader.completeFeedLoading(with: [item0, item1], at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancel image url request until views become visible")
        
        sut.simulateFeedImageViewDissapeared(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [item0.url], "Expected first image url cancel request once the first view dissapears")
        
        sut.simulateFeedImageViewVisible(at: 1)
        sut.simulateFeedImageViewDissapeared(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [item0.url, item1.url], "Expected second image url cancel request once the second view dissapears")
    }
    
    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let (sut, loader) = makeSUT()
        
        sut.simulateViewAppearance()
        loader.completeFeedLoading(with: [uniqueFeedImage(), uniqueFeedImage()], at: 0)
        
        let imageView0 = sut.simulateFeedImageViewVisible(at: 0)
        let imageView1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(imageView0?.isViewShimmering, true, "Expect the first image view to shimmer when its visible and image data is loading")
        XCTAssertEqual(imageView1?.isViewShimmering, true, "Expect the second image view to shimmer when its visible and image data is loading")

        loader.completeImageDataLoadingWithSuccess(at: 0)
        XCTAssertEqual(imageView0?.isViewShimmering, false, "Expect the first image view to stop shimmering when the image data is loaded with success")
        XCTAssertEqual(imageView1?.isViewShimmering, true, "Expect the second image view to continue shimmering until while timage data is loading")
  
        loader.completeImageDataLoadingWithFailure(at: 1)
        XCTAssertEqual(imageView0?.isViewShimmering, false, "Expect the first image view to continue to have no shimmer after image data was loaded")
        XCTAssertEqual(imageView1?.isViewShimmering, false, "Expect the second image view to stop shimmering when the image data is loaded with failure")
    }
    
    func test_feedImageView_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()
        
        sut.simulateViewAppearance()
        loader.completeFeedLoading(with: [uniqueFeedImage(), uniqueFeedImage()], at: 0)
        
        let imageView0 = sut.simulateFeedImageViewVisible(at: 0)
        let imageView1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(imageView0?.renderedImage, .none, "Expect no rendered image in the first image view until the image is loaded from url")
        XCTAssertEqual(imageView1?.renderedImage, .none, "Expect no rendered image in the second image view until the image is loaded from url")

        let imageData0 = UIImage.make(withColor: .red).pngData()
        loader.completeImageDataLoadingWithSuccess(with: imageData0, at: 0)
        XCTAssertEqual(imageView0?.renderedImage, imageData0, "Expect the first image to render after loading it")
        XCTAssertEqual(imageView1?.renderedImage, .none, "Expect the second image view to have no image until its loaded")
  
        let imageData1 = UIImage.make(withColor: .blue).pngData()
        loader.completeImageDataLoadingWithSuccess(with: imageData1, at: 1)
        XCTAssertEqual(imageView0?.renderedImage, imageData0, "Expect the first image to render after loading it")
        XCTAssertEqual(imageView1?.renderedImage, imageData1, "Expect the second image to render after loading it")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: FeedLoaderSpy) {
        let loader = FeedLoaderSpy()
        let sut = FeedViewController(feedLoader: loader, imageLoader: loader)
        
        checkForMemoryLeaks(for: loader, file: file, line: line)
        checkForMemoryLeaks(for: sut, file: file, line: line)
        
        return (sut: sut, loader: loader)
    }
    
    private func assertThat(_ sut: FeedViewController, isRendering items: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        guard sut.numberOfRenderedFeedImageViews() == items.count else {
            XCTFail("Expected to render \(items.count) items, but it rendered \(sut.numberOfRenderedFeedImageViews()) instead", file: file, line: line)
            return
        }
        
        items.enumerated().forEach { (index, item) in
            assertThat(sut, hasViewConfiguredFor: item, at: index, file: file, line: line)
        }
    }
    
    private func assertThat(_ sut: FeedViewController, hasViewConfiguredFor item: FeedImage, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        guard let feedImageCell = sut.getFeedImageView(at: index) else {
            XCTFail("Expected to get feed image from view, using index \(index) but failed instead", file: file, line: line)
            return
        }
        
        let isItemLocationVisible = item.location != nil
        XCTAssertEqual(feedImageCell.isLocationVisible, isItemLocationVisible, "Expected cell location visibility to be \(isItemLocationVisible), but got \(feedImageCell.isLocationVisible) instead", file: file, line: line)
        XCTAssertEqual(feedImageCell.descriptionText, item.description, "Expected cell description to be \(String(describing: item.description)), but got \(String(describing: feedImageCell.descriptionText)) instead", file: file, line: line)
        XCTAssertEqual(feedImageCell.locationText, item.location, "Expected cell location to be \(String(describing: item.location)), but got \(String(describing: feedImageCell.locationText)) instead", file: file, line: line)
    }
    
    private func uniqueFeedImage(url: URL = URL(string: "http://any-url.com")!, description: String? = nil, location: String? = nil) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    class FeedLoaderSpy: FeedLoader, FeedImageDataLoader {
        
        // MARK: Feed Loader
        private var feedRequests = [(FeedLoader.Result) -> Void]()
        
        var loadFeedCallCount: Int {
            feedRequests.count
        }
        
        func loadFeed(completion: @escaping (FeedLoader.Result) -> Void) {
            feedRequests.append(completion)
        }
        
        func completeFeedLoading(with images: [FeedImage] = [], at index: Int) {
            feedRequests[index](.success(images))
        }
        
        func completeFeedLoadingWithError(at index: Int) {
            feedRequests[index](.failure(anyNSError()))
        }
        
        // MARK: Image Data Loader
        typealias LoadImageCompletion = (FeedImageDataLoader.Result) -> Void
        
        private(set) var loadImageRequests = [(url: URL, completion: LoadImageCompletion)]()
        private(set) var cancelledImageURLs = [URL]()
        
        var loadedImages: [URL] {
            return loadImageRequests.map { $0.url }
        }
        
        private struct FeedImageDataLoaderTaskSpy: FeedImageDataLoaderTask {
            let cancelAction: () -> Void
            
            func cancel() {
                cancelAction()
            }
        }
        
        func loadImageData(from url: URL, completion: @escaping LoadImageCompletion) -> FeedImageDataLoaderTask {
            loadImageRequests.append((url: url, completion: completion))
            
            return FeedImageDataLoaderTaskSpy { [weak self] in
                self?.cancelledImageURLs.append(url)
            }
        }
        
        func completeImageDataLoadingWithSuccess(with data: Data? = nil, at index: Int) {
            loadImageRequests[index].completion(.success(data ?? anyData()))
        }
        
        func completeImageDataLoadingWithFailure(at index: Int) {
            loadImageRequests[index].completion(.failure(anyNSError()))
        }
    }
}

private extension FeedViewController {
    func numberOfRenderedFeedImageViews() -> Int {
        return tableView.numberOfRows(inSection: imageFeedSection)
    }
    
    private var imageFeedSection: Int {
        return 0
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        return getFeedImageView(at: index)
    }
    
    func getFeedImageView(at index: Int) -> FeedImageCell? {
        let ds = tableView.dataSource
        let indexPath = IndexPath(item: index, section: imageFeedSection)
        return ds?.tableView(tableView, cellForRowAt: indexPath) as? FeedImageCell
    }
    
    func simulateFeedImageViewDissapeared(at index: Int) {
        let visibleImageView = simulateFeedImageViewVisible(at: index)
        
        let delegate = tableView.delegate
        let indexPath = IndexPath(item: index, section: imageFeedSection)
        delegate?.tableView?(tableView, didEndDisplaying: visibleImageView!, forRowAt: indexPath)
    }
}

private extension FeedImageCell {
    var isLocationVisible: Bool {
        locationLabel.isHidden == false
    }
    
    var descriptionText: String? {
        descriptionLabel.text
    }
    
    var locationText: String? {
        locationLabel.text
    }
    
    var isViewShimmering: Bool {
        imageContainer.isShimmering
    }
    
    var renderedImage: Data? {
        feedImageView.image?.pngData()
    }
}

private extension FeedViewController {
    func simulateUserInitiatedFeedLoad() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingRefreshIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
    
    func simulateViewAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded()
            replaceRefreshControlWithFake()
        }
        
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    func replaceRefreshControlWithFake() {
        let fake = FakeRefreshControl()
        
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                fake.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }
        
        refreshControl = fake
    }
}

private class FakeRefreshControl: UIRefreshControl {
    private var _isRefreshing: Bool = false
    
    override var isRefreshing: Bool {
        return _isRefreshing
    }
    
    override func beginRefreshing() {
        _isRefreshing = true
    }
    
    override func endRefreshing() {
        _isRefreshing = false
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

private extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
            color.setFill()
            rendererContext.fill(rect)
        }
    }
}
