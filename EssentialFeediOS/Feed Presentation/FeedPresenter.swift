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
    private let feedView: FeedView
    private let feedLoadingView: FeedLoadingView

    init(feedView: FeedView, feedLoadingView: FeedLoadingView) {
        self.feedView = feedView
        self.feedLoadingView = feedLoadingView
    }
    
    static var title: String {
        return String(localized: LocalizedStringResource.Feed.feedViewTitle)
    }

    func didStartLoadingFeed() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in self?.didStartLoadingFeed() }
            return
        }
        feedLoadingView.display(FeedLoadingViewModel(isLoading: true))
    }

    func didFinishLoadingFeed(with feed: [FeedImage]) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in self?.didFinishLoadingFeed(with: feed) }
            return
        }
        feedView.display(FeedViewModel(feed: feed))
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
    }

    func didFinishLoadingFeed(with error: Error) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in self?.didFinishLoadingFeed(with: error) }
            return
        }
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
