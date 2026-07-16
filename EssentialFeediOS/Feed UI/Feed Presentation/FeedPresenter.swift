import Foundation
import EssentialFeed

protocol FeedView {
    func display(feed: [FeedImage])
}

protocol FeedLoadingView: AnyObject {
    func display(isLoading: Bool)
}

final class FeedPresenter {
    private let feedLoader: FeedLoader
    
    var feedView: FeedView?
    weak var feedLoadingView: FeedLoadingView?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        feedLoadingView?.display(isLoading: true)
        
        feedLoader.loadFeed { [weak self] result in
            guard let self else { return }
            if let feed = try? result.get() {
                feedView?.display(feed: feed)
            }
            feedLoadingView?.display(isLoading: false)
        }
    }
}
