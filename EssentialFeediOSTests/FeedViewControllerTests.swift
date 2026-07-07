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
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: FeedLoaderSpy) {
        let loader = FeedLoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        checkForMemoryLeaks(for: loader, file: file, line: line)
        checkForMemoryLeaks(for: sut, file: file, line: line)
        
        return (sut: sut, loader: loader)
    }
    
    class FeedLoaderSpy: FeedLoader {
        private var completions = [(FeedLoader.Result) -> Void]()
        
        var loadCallCount: Int {
            completions.count
        }
        
        func loadFeed(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading(at index: Int) {
            completions[index](.success([]))
        }
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
