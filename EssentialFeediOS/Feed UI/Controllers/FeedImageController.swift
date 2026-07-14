import UIKit
import EssentialFeed

final class FeedImageController {
    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader

    private(set) var view: FeedImageCell?

    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func createView() -> FeedImageCell {
        let feedImageCell = FeedImageCell()
        feedImageCell.locationLabel.isHidden = model.location == nil
        feedImageCell.locationLabel.text = model.location
        feedImageCell.descriptionLabel.text = model.description
        
        feedImageCell.feedImageRetryButton.isHidden = true
        feedImageCell.feedImageView.image = nil
        feedImageCell.imageContainer.startShimmering()
        
        feedImageCell.onRetry = { [weak self] in
            guard let self else { return }
            loadImage()
        }
        loadImage()
        
        view = feedImageCell
        return view!
    }
    
    func loadImage() {
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            guard let self, let view else { return }
            let data = try? result.get()
            let image = data.flatMap(UIImage.init)
            view.feedImageView.image = image
            view.feedImageRetryButton.isHidden = image != nil
            view.imageContainer.stopShimmering()
        }
    }
    
    func prefetch() {
        task = imageLoader.loadImageData(from: model.url) { _ in }
    }
    
    deinit {
        task?.cancel()
    }
}
