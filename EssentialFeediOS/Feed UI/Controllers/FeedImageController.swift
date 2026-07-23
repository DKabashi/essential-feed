import UIKit

protocol FeedImageControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

final class FeedImageController: FeedImageView {
    private let delegate: FeedImageControllerDelegate
    private var cell: FeedImageCell?

    init(delegate: FeedImageControllerDelegate) {
        self.delegate = delegate
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeReusableCell()
        delegate.didRequestImage()
        return cell!
    }
    
    func prefetch() {
        delegate.didRequestImage()
    }
    
    func cancelTask() {
        cell = nil
        delegate.didCancelImageRequest()
    }
    
    func display(_ model: FeedImageViewModel<UIImage>) {
        cell?.locationLabel.isHidden = !model.hasLocation
        cell?.locationLabel.text = model.location
        cell?.descriptionLabel.text = model.description
        cell?.onRetry = delegate.didRequestImage
        
        cell?.feedImageView.image = model.image
        cell?.feedImageRetryButton.isHidden = !model.shouldRetry
        
        if model.isLoading {
            cell?.imageContainer.startShimmering()
        } else {
            cell?.imageContainer.stopShimmering()
        }
    }
}
