import XCTest
import EssentialFeed
import EssentialFeediOS

final class FeedViewControllerTests: XCTestCase {

    func test_feedView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.simulateViewAppearance()
      
        XCTAssertEqual(sut.title, localized("FEED_VIEW_TITLE"))
    }
    
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
        XCTAssertEqual(loader.loadedImageRequestURLs, [], "Expected no image url request until views become visible")
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageRequestURLs, [item0.url], "Expected first image url request once the first view becomes visible")
        
        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageRequestURLs, [item0.url, item1.url], "Expected second image url request once the second view becomes visible")
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
    
    func test_feedImageRetryButton_isVisibleOnImageLoadFail() {
        let (sut, loader) = makeSUT()
        
        sut.simulateViewAppearance()
        loader.completeFeedLoading(with: [uniqueFeedImage(), uniqueFeedImage()], at: 0)
        
        let imageView0 = sut.simulateFeedImageViewVisible(at: 0)
        let imageView1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(imageView0?.renderedImage, .none, "Expected no retry action for first view while loading first image")
        XCTAssertEqual(imageView1?.renderedImage, .none, "Expected no retry action for second view while loading second image")

        let imageData = UIImage.make(withColor: .blue).pngData()
        loader.completeImageDataLoadingWithSuccess(with: imageData, at: 0)
        XCTAssertEqual(imageView0?.isRetryButtonVisible, false, "Expected no retry action for first view once first image loading completes successfully")
        XCTAssertEqual(imageView1?.isRetryButtonVisible, false, "Expected no retry action state change for second view once first image loading completes successfully")
  
        loader.completeImageDataLoadingWithFailure(at: 1)
        XCTAssertEqual(imageView0?.isRetryButtonVisible, false, "Expected no retry action state change for first view once second image loading completes with error")
        XCTAssertEqual(imageView1?.isRetryButtonVisible, true, "Expected retry action for second view once second image loading completes with error")
    }
    
    func test_feedImageRetryButton_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()
        
        sut.simulateViewAppearance()
        loader.completeFeedLoading(with: [uniqueFeedImage()], at: 0)
        
        let imageView = sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(imageView?.isRetryButtonVisible, false)
        
        let data = Data("Invalid Data".utf8)
        loader.completeImageDataLoadingWithSuccess(with: data, at: 0)
        XCTAssertEqual(imageView?.isRetryButtonVisible, true)
    }
    
    func test_feedImageRetryAction_retriesImageLoad() {
        let (sut, loader) = makeSUT()
        let url0 = URL(string: "http://url-0.com")!
        let url1 = URL(string: "http://url-1.com")!
        
        sut.simulateViewAppearance()
        loader.completeFeedLoading(with: [uniqueFeedImage(url: url0), uniqueFeedImage(url: url1)], at: 0)
        let imageView0 = sut.simulateFeedImageViewVisible(at: 0)!
        let imageView1 = sut.simulateFeedImageViewVisible(at: 1)!
        
        loader.completeImageDataLoadingWithFailure(at: 0)
        loader.completeImageDataLoadingWithFailure(at: 1)
        XCTAssertEqual(loader.loadedImageRequestURLs, [url0, url1])
        
        imageView0.simulateRetryButtonTap()
        XCTAssertEqual(loader.loadedImageRequestURLs, [url0, url1, url0])
        
        imageView1.simulateRetryButtonTap()
        XCTAssertEqual(loader.loadedImageRequestURLs, [url0, url1, url0, url1])
    }
    
    func test_feedImageView_preloadsImageURLWhenNearVisible() {
        let (sut, loader) = makeSUT()
        let url0 = URL(string: "http://url-0.com")!
        let url1 = URL(string: "http://url-1.com")!
    
        sut.simulateViewAppearance()
        loader.completeFeedLoading(with: [uniqueFeedImage(url: url0), uniqueFeedImage(url: url1)], at: 0)
        XCTAssertEqual(loader.loadedImageRequestURLs, [])
        
        sut.simulateFeedImageViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageRequestURLs, [url0])
        
        sut.simulateFeedImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageRequestURLs, [url0, url1])
    }
    
    func test_feedImageView_cancelsPreloadImageURLWhenNoLongerNearVisible() {
        let (sut, loader) = makeSUT()
        let url0 = URL(string: "http://url-0.com")!
        let url1 = URL(string: "http://url-1.com")!
    
        sut.simulateViewAppearance()
        loader.completeFeedLoading(with: [uniqueFeedImage(url: url0), uniqueFeedImage(url: url1)], at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [])
        
        sut.simulateFeedImageNotNearVisibleAnymore(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [url0])
        
        sut.simulateFeedImageNotNearVisibleAnymore(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [url0, url1])
    }
    
    func test_feedImageView_doesNotRenderLoadedImageAfterCellNotVisibleAnymore() {
        let (sut, loader) = makeSUT()
        sut.simulateViewAppearance()
        loader.completeFeedLoading(with: [uniqueFeedImage(url: anyURL())], at: 0)
        
        let view = sut.simulateFeedImageViewDissapeared(at: 0)
        loader.completeImageDataLoadingWithSuccess(with: anyImageData(), at: 0)
        XCTAssertNil(view?.renderedImage)
    }
    
    func test_feedImageView_doesNotRenderImageOfPreviousCellThatNeverBecameVisible() throws {
        let (sut, loader) = makeSUT()
                
        sut.simulateViewAppearance()
        loader.completeFeedLoading(with: [uniqueFeedImage(url: anyURL()), uniqueFeedImage(url: anyURL())], at: 0)
        
        let view0 = try XCTUnwrap(sut.simulateFeedImageViewVisible(at: 0))
        view0.prepareForReuse()
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageDataLoadingWithSuccess(with: imageData0, at: 0)
        
        XCTAssertEqual(view0.renderedImage, .none, "Expected no image state change for reused view once image loading completes successfully")
    }
    
    func test_feedImageView_showsDataForNewViewRequestAfterPreviousViewIsReused() throws {
        let (sut, loader) = makeSUT()
        
        sut.simulateViewAppearance()
        loader.completeFeedLoading(with: [uniqueFeedImage(url: anyURL()), uniqueFeedImage(url: anyURL())], at: 0)
        
        let previousView = try XCTUnwrap(sut.simulateFeedImageViewDissapeared(at: 0))
        
        let newView = try XCTUnwrap(sut.simulateFeedImageViewVisible(at: 0))
        previousView.prepareForReuse()
        
        let imageData = UIImage.make(withColor: .red).pngData()!
        loader.completeImageDataLoadingWithSuccess(with: imageData, at: 1)
        
        XCTAssertEqual(newView.renderedImage, imageData)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: FeedLoaderSpy) {
        let loader = FeedLoaderSpy()
        let sut = FeedUIComposer.composeWith(feedLoader: loader, imageLoader: loader)
        
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
    
    private func anyImageData() -> Data {
        return UIImage.make(withColor: .blue).pngData()!
    }
}
