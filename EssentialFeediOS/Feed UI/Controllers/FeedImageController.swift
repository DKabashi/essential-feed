import UIKit

final class FeedImageController {
    private let viewModel: FeedImageViewModel<UIImage>

    init(viewModel: FeedImageViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    func view() -> UITableViewCell {
        let view = binded(FeedImageCell())
        viewModel.loadImageData()
        return view
    }
    
    func prefetch() {
        viewModel.loadImageData()
    }
    
    func cancelTask() {
        viewModel.cancelImageDataLoad()
    }
    
    private func binded(_ view: FeedImageCell) -> FeedImageCell {
        view.locationLabel.isHidden = !viewModel.hasLocation
        view.locationLabel.text = viewModel.location
        view.descriptionLabel.text = viewModel.description
        view.onRetry = viewModel.loadImageData
        
        viewModel.onImageLoad = { [weak view] image in
            view?.feedImageView.image = image
        }
        
        viewModel.onImageLoadingStateChange = { [weak view] isLoading in
            if isLoading {
                view?.imageContainer.startShimmering()
            } else {
                view?.imageContainer.stopShimmering()
            }
        }
        
        viewModel.onShouldRetryImageLoadStateChange = { [weak view] shouldRetry in
            view?.feedImageRetryButton.isHidden = !shouldRetry
        }
        
        return view
    }
}
