import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func composeWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presenterAdapter = FeedLoadPresentationAdapter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(delegate: presenterAdapter)

        let feedViewController = FeedViewController(refreshController: refreshController)
        let feedAdapter = FeedAdapter(controller: feedViewController, loader: imageLoader)
        
        let feedPresenter = FeedPresenter(feedView: feedAdapter, feedLoadingView: WeakRefVirtualProxy(object: refreshController))
        presenterAdapter.presenter = feedPresenter
        
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

final class FeedLoadPresentationAdapter: FeedRefreshViewControllerDelegate {
    private let feedLoader: FeedLoader
    var presenter: FeedPresenter?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        
        feedLoader.loadFeed { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}
