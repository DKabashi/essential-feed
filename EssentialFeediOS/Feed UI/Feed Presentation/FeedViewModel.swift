import Foundation
import EssentialFeed

final class FeedViewModel {
    typealias Observer<T> = (T) -> Void

    private let feedLoader: FeedLoader
    
    var onLoadingStateChange: Observer<Bool>?
    var onFeedLoad: Observer<[FeedImage]>?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        onLoadingStateChange?(true)
        
        feedLoader.loadFeed { [weak self] result in
            guard let self else { return }
            if let feed = try? result.get() {
                onFeedLoad?(feed)
            }
            onLoadingStateChange?(false)
        }
    }
}
