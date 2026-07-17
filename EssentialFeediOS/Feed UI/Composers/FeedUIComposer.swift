import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func composeWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedPresenter = FeedPresenter(feedLoader: feedLoader)
        
        let refreshController = FeedRefreshViewController(presenter: feedPresenter)
        feedPresenter.feedLoadingView = WeakRefVirtualProxy(object: refreshController)
        
        let feedViewController = FeedViewController(refreshController: refreshController)
        let feedAdapter = FeedAdapter(controller: feedViewController, loader: imageLoader)
        feedPresenter.feedView = feedAdapter
        
        return feedViewController
    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    weak var object: T?
    
    init(object: T? = nil) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

final class FeedAdapter: FeedView {
    weak var controller: FeedViewController?
    let loader: FeedImageDataLoader
    
    init(controller: FeedViewController, loader: FeedImageDataLoader) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map {
            let viewModel = FeedImageViewModel(feedImage: $0, imageLoader: loader, imageTransformer: UIImage.init)
            return FeedImageController(viewModel: viewModel)
        }
    }
}
