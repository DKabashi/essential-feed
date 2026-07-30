import UIKit
import EssentialFeed

protocol FeedImageControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

final class FeedImageController: FeedImageView, LoadingView, RetryView {
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
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }
    
    func display(_ model: FeedImageViewModel<UIImage>) {
        cell?.locationStackView.isHidden = !model.hasLocation
        cell?.locationLabel.text = model.location
        cell?.descriptionLabel.text = model.description
        cell?.onRetry = { [weak self] in
            self?.delegate.didRequestImage()
        }

        cell?.onReuse = { [weak self] in
            self?.releaseCellForReuse()
        }

        cell?.feedImageView.setImageWithFadeAnimation(model.image)
    }
    
    func display(_ viewModel: LoadingViewModel) {
        if viewModel.isLoading {
            cell?.imageContainer.startShimmering()
        } else {
            cell?.imageContainer.stopShimmering()
        }
    }
    
    func display(_ model: RetryViewModel) {
        cell?.feedImageRetryButton.isHidden = !model.shouldRetry
    }
    
    private func releaseCellForReuse() {
        cell?.onReuse = nil
        cell?.onRetry = nil
        cell = nil
    }
}
