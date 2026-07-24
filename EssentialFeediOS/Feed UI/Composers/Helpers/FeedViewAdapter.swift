import UIKit

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

            presentationAdapter.presenter = FeedImagePresenter(view: WeakRefVirtualProxy(object: feedImageController), imageTransformer: UIImage.init)
            return feedImageController
        }
    }
}
