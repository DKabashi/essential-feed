import Foundation
import EssentialFeed

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

final class FeedPresenter {
    var feedView: FeedView?
    var feedLoadingView: FeedLoadingView?

    func didStartLoadingFeed() {
        feedLoadingView?.display(FeedLoadingViewModel(isLoading: true))
    }

    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView?.display(FeedViewModel(feed: feed))
        feedLoadingView?.display(FeedLoadingViewModel(isLoading: false))
    }

    func didFinishLoadingFeed(with error: Error) {
        feedLoadingView?.display(FeedLoadingViewModel(isLoading: false))
    }
}
