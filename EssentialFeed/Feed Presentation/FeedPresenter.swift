import Foundation

public final class FeedPresenter {
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    
    static public var title: String {
        return String(localized: LocalizedStringResource.Feed.feedViewTitle)
    }
    
    public var feedLoadError: String {
        return String(localized: LocalizedStringResource.Feed.feedViewConnectionError)
    }
    
    public init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.feedView = feedView
        self.errorView = errorView
        self.loadingView = loadingView
    }
    
    public func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
