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
    public typealias SaveResult = Result<Void, Error>
    
    public func save(feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        feedStore.deleteCachedFeed { [weak self] deletionResult in
            guard let self else { return }
            
            switch deletionResult {
            case .success:
                cache(feed: feed, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func cache(feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        feedStore.insert(feed.localFeed, timestamp: createTimestamp(), completion: { [weak self] insertionResult in
            guard self != nil else { return }
            
            completion(insertionResult)
        })
    }
}

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = FeedLoader.Result
    
    public func loadFeed(completion: @escaping (LoadResult) -> Void) {
        feedStore.retrieve { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .success(let .some(cachedFeed)):
                completion(.success(cachedFeed.feed.feedImages))
            case .success(.none):
                completion(.success([]))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension LocalFeedLoader {
    public typealias ValidationResult = Result<Void, Error>

    public func validateCache(completion: @escaping (ValidationResult) -> Void) {
        feedStore.retrieve { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure:
                feedStore.deleteCachedFeed(completion: completion)
            case .success(.some(let cachedFeed)) where FeedCachePolicy.isExpired(timestamp: cachedFeed.timestamp, against: createTimestamp()):
                feedStore.deleteCachedFeed { _ in completion(.success(())) }
            case .success:
                completion(.success(()))
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
