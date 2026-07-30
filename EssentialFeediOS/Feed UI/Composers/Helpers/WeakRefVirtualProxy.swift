import UIKit
import EssentialFeed

final class WeakRefVirtualProxy<T: AnyObject> {
    weak var object: T?
    
    init(object: T? = nil) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: LoadingView where T: LoadingView {
    func display(_ viewModel: LoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ model: FeedImageViewModel<UIImage>) {
        object?.display(model)
    }
}

extension WeakRefVirtualProxy: FeedErrorView where T: FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel) {
        object?.display(viewModel)
    }
}

