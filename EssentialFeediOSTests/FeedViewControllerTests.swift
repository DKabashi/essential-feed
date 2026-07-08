import XCTest
import EssentialFeed
import EssentialFeediOS

final class FeedViewControllerTests: XCTestCase {

    func test_loadFeedActions_requestFeedLoadInOrder() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0, "Expect no feed loading on VC init")
        
        sut.simulateViewAppearance()
        XCTAssertEqual(loader.loadCallCount, 1, "Expect the feed to load on viewDidLoad")
        
        sut.simulateUserInitiatedFeedLoad()
        XCTAssertEqual(loader.loadCallCount, 2, "Expect the feed to load again after user initiates a feed load")
        
        sut.simulateUserInitiatedFeedLoad()
        XCTAssertEqual(loader.loadCallCount, 3, "Expect the feed to load for the third time after another user initiates a feed load")
    }
    
    func test_refreshIndicator_changesVisibilityBasedOnIsFeedLoading() {
        let (sut, loader) = makeSUT()

        sut.simulateViewAppearance()
        XCTAssertTrue(sut.isShowingRefreshIndicator, "Expect loading indicator to show after on viewDidLoad")

        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingRefreshIndicator, "Expect loading indicator to hide after the feed load is finished")
  
        sut.simulateUserInitiatedFeedLoad()
        XCTAssertTrue(sut.isShowingRefreshIndicator, "Expect loading indicator to show again after on user initiated feed load")
        
        loader.completeFeedLoading(at: 1)
        XCTAssertFalse(sut.isShowingRefreshIndicator, "Expect loading indicator to hide again after the user initiated feed load is finished")
        
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
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: FeedLoaderSpy) {
        let loader = FeedLoaderSpy()
        let sut = FeedViewController(loader: loader)
        
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
    
    private func uniqueFeedImage(description: String? = nil, location: String? = nil) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, url: URL(string: "http://any-url.com")!)
    }
    
    class FeedLoaderSpy: FeedLoader {
        private var completions = [(FeedLoader.Result) -> Void]()
        
        var loadCallCount: Int {
            completions.count
        }
        
        func loadFeed(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading(with images: [FeedImage] = [], at index: Int) {
            completions[index](.success(images))
        }
        
        func completeFeedLoadingWithError(at index: Int) {
            completions[index](.failure(anyNSError()))
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
    
    func getFeedImageView(at index: Int) -> FeedImageCell? {
        let ds = tableView.dataSource
        let indexPath = IndexPath(item: index, section: imageFeedSection)
        return ds?.tableView(tableView, cellForRowAt: indexPath) as? FeedImageCell
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
