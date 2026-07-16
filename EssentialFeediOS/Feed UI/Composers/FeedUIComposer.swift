import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func composeWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedViewController = FeedViewController(refreshController: refreshController)
        feedViewModel.onFeedLoad = adaptFeedToImageController(forwardingTo: feedViewController, loader: imageLoader)
        return feedViewController
    }
    
    private static func adaptFeedToImageController(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> (([FeedImage]) -> Void) {
        return { [weak controller] feed in
            controller?.tableModel = feed.map {
                let viewModel = FeedImageViewModel(feedImage: $0, imageLoader: loader)
                return FeedImageController(viewModel: viewModel)
            }
            
        }
    }
}
