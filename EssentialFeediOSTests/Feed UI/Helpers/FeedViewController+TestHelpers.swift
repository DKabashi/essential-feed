import UIKit
import EssentialFeediOS

extension FeedViewController {
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
    
    @discardableResult
    func simulateFeedImageViewDissapeared(at index: Int) -> FeedImageCell? {
        let visibleImageView = simulateFeedImageViewVisible(at: index)
        
        let delegate = tableView.delegate
        let indexPath = IndexPath(item: index, section: imageFeedSection)
        delegate?.tableView?(tableView, didEndDisplaying: visibleImageView!, forRowAt: indexPath)
        
        return visibleImageView
    }
    
    func simulateFeedImageViewNearVisible(at index: Int) {
        let ds = tableView.prefetchDataSource
        let indexPath = IndexPath(item: index, section: imageFeedSection)
        ds?.tableView(tableView, prefetchRowsAt: [indexPath])
    }
    
    func simulateFeedImageNotNearVisibleAnymore(at index: Int) {
        simulateFeedImageViewNearVisible(at: index)
        let ds = tableView.prefetchDataSource
        let indexPath = IndexPath(item: index, section: imageFeedSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }
}

extension FeedViewController {
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
        
        refreshController?.view = fake
        refreshControl = fake
    }
}
