import Foundation

public final class LocalFeedLoader {
    private var feedStore: FeedStore
    private var createTimestamp: () -> Date
    private let calendar = Calendar(identifier: .gregorian)
    
    public init(store: FeedStore, createTimestamp: @escaping () -> Date) {
        feedStore = store
        self.createTimestamp = createTimestamp
    }
}

extension LocalFeedLoader {
    public typealias SaveResult = NSError?
    
    public func save(feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        feedStore.deleteCachedFeed { [weak self] deletionError in
            guard let self else { return }
            if let error = deletionError {
                completion(error)
            } else {
                cache(feed: feed, completion: completion)
            }
        }
    }
    
    private func cache(feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        feedStore.insert(feed.localFeed, timestamp: createTimestamp(), completion: { [weak self] insertionError in
            guard self != nil else { return }
            
            completion(insertionError)
        })
    }
}

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = FeedLoader.Result
    
    public func loadFeed(completion: @escaping (LoadResult) -> Void) {
        feedStore.retrieve { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .success(let localFeedItems, _):
                completion(.success(localFeedItems.feedImages))
            case .empty:
                completion(.success([]))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension LocalFeedLoader {
    public func validateCache() {
        feedStore.retrieve { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure:
                feedStore.deleteCachedFeed { _ in }
            case .success(_, let timestamp) where FeedCachePolicy.isExpired(timestamp: timestamp, against: createTimestamp()):
                feedStore.deleteCachedFeed { _ in }
            case .empty, .success:
                break
            }
        }
    }
}

private extension Array where Element == FeedImage {
    var localFeed: [LocalFeedImage] {
        self.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

private extension Array where Element == LocalFeedImage {
    var feedImages: [FeedImage] {
        self.map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
