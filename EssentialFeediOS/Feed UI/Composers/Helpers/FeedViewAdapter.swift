import UIKit
import EssentialFeed

final class FeedViewAdapter: FeedView {
    weak var controller: FeedViewController?
    let loader: FeedImageDataLoader
    
    init(controller: FeedViewController, loader: FeedImageDataLoader) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map {
            let presentationAdapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageController>, UIImage>(imageLoader: loader, feedImage: $0)
            let feedImageController = FeedImageController(delegate: presentationAdapter)
            let weakImageController = WeakRefVirtualProxy(object: feedImageController)
            presentationAdapter.presenter = FeedImagePresenter(imageView: weakImageController, loadingView: weakImageController, retryView: weakImageController, imageTransformer: UIImage.init)
            return feedImageController
        }
    }
}
