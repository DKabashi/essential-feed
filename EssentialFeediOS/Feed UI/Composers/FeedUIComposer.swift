import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func composeWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presenterAdapter = FeedLoadPresentationAdapter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(delegate: presenterAdapter)
        let feedViewController = FeedViewController(refreshController: refreshController)
        feedViewController.title = FeedPresenter.title

        presenterAdapter.presenter = FeedPresenter(
            feedView: FeedViewAdapter(controller: feedViewController, loader: imageLoader),
            feedLoadingView: WeakRefVirtualProxy(object: refreshController)
        )

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

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ model: FeedImageViewModel<UIImage>) {
        object?.display(model)
    }
}

private final class FeedViewAdapter: FeedView {
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

private final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageControllerDelegate where Image == View.Image {
    private var task: FeedImageDataLoaderTask?

    private let imageLoader: FeedImageDataLoader
    private let feedImage: FeedImage
    
    init(imageLoader: FeedImageDataLoader, feedImage: FeedImage) {
        self.imageLoader = imageLoader
        self.feedImage = feedImage
    }
    
    var presenter: FeedImagePresenter<View, Image>?
    
    func didRequestImage() {
        presenter?.didStartLoadingImage(model: feedImage)

        task = imageLoader.loadImageData(from: feedImage.url) { [weak self] result in
            guard let self else { return }
            do {
                let image = try result.get()
                presenter?.didFinishLoadingImage(with: image, model: feedImage)
            } catch {
                presenter?.didFinishLoadingImageWithError(error, model: feedImage)
            }
        }
    }
    
    func didCancelImageRequest() {
        task?.cancel()
        task = nil
    }
}

private final class FeedLoadPresentationAdapter: FeedRefreshViewControllerDelegate {
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
