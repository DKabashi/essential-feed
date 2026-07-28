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

struct FeedErrorViewModel {
    let message: String
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {
    private let feedView: FeedView
    private let feedLoadingView: FeedLoadingView
    private let errorView: FeedErrorView

    init(feedView: FeedView, feedLoadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.feedView = feedView
        self.feedLoadingView = feedLoadingView
        self.errorView = errorView
    }
    
    static var title: String {
        return String(localized: LocalizedStringResource.Feed.feedViewTitle)
    }
    
    private var feedLoadError: String {
        return String(localized: LocalizedStringResource.Feed.feedViewConnectionError)
    }

    func didStartLoadingFeed() {
        feedLoadingView.display(FeedLoadingViewModel(isLoading: true))
    }

    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
    }

    func didFinishLoadingFeed(with error: Error) {
        errorView.display(FeedErrorViewModel(message: feedLoadError))
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
