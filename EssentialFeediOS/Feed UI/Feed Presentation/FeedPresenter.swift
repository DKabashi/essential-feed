import Foundation
import EssentialFeed

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

final class FeedPresenter {
    private let feedLoader: FeedLoader
    
    var feedView: FeedView?
    var feedLoadingView: FeedLoadingView?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        feedLoadingView?.display(FeedLoadingViewModel(isLoading: true))
        
        feedLoader.loadFeed { [weak self] result in
            guard let self else { return }
            if let feed = try? result.get() {
                feedView?.display(FeedViewModel(feed: feed))
            }
            feedLoadingView?.display(FeedLoadingViewModel(isLoading: false))
        }
    }
}
