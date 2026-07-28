import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func composeWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presenterAdapter = FeedLoadPresentationAdapter(feedLoader: MainQueueDispatchDecorator(decoratee: feedLoader))
        let refreshController = FeedRefreshViewController(delegate: presenterAdapter)
        let feedViewController = FeedViewController(refreshController: refreshController)
        feedViewController.title = FeedPresenter.title

        presenterAdapter.presenter = FeedPresenter(
            feedView: FeedViewAdapter(controller: feedViewController, loader: MainQueueDispatchDecorator(decoratee: imageLoader)),
            feedLoadingView: WeakRefVirtualProxy(object: refreshController),
            errorView: WeakRefVirtualProxy(object: feedViewController)
        )

        return feedViewController
    }
}
