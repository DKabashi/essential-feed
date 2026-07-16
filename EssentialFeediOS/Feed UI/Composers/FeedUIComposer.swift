import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func composeWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        //let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let feedPresenter = FeedPresenter(feedLoader: feedLoader)
        
        let refreshController = FeedRefreshViewController(presenter: feedPresenter)
        feedPresenter.feedLoadingView = refreshController
        
        let feedViewController = FeedViewController(refreshController: refreshController)
        let feedAdapter = FeedAdapter(controller: feedViewController, loader: imageLoader)
        
        feedPresenter.feedView = feedAdapter
        
        return feedViewController
    }
}

final class FeedAdapter: FeedView {
    weak var controller: FeedViewController?
    let loader: FeedImageDataLoader
    
    init(controller: FeedViewController, loader: FeedImageDataLoader) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(feed: [FeedImage]) {
        controller?.tableModel = feed.map {
            let viewModel = FeedImageViewModel(feedImage: $0, imageLoader: loader, imageTransformer: UIImage.init)
            return FeedImageController(viewModel: viewModel)
        }
    }
}
