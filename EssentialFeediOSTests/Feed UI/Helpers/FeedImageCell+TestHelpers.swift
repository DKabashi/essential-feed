import UIKit
import EssentialFeediOS

extension FeedImageCell {
    var isLocationVisible: Bool {
        locationStackView.isHidden == false
    }
    
    var descriptionText: String? {
        descriptionLabel.text
    }
    
    var locationText: String? {
        locationLabel.text
    }
    
    var isViewShimmering: Bool {
        imageContainer.isShimmering
    }
    
    var renderedImage: Data? {
        feedImageView.image?.pngData()
    }
    
    var isRetryButtonVisible: Bool {
        !feedImageRetryButton.isHidden
    }
    
    func simulateRetryButtonTap() {
        feedImageRetryButton.simulateRetryButtonTap()
    }
}
