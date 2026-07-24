import Foundation
import EssentialFeed

final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageControllerDelegate where Image == View.Image {
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
