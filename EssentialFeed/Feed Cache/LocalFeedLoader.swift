import Foundation

public final class LocalFeedLoader {
    private var feedStore: FeedStore
    private var createTimestamp: () -> Date
    
    public typealias SaveResult = NSError?
    public typealias LoadResult = Result<[FeedImage]?, NSError>
    
    public init(store: FeedStore, createTimestamp: @escaping () -> Date) {
        feedStore = store
        self.createTimestamp = createTimestamp
    }
    
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
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        feedStore.retrieve { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success((_, timestamp)):
                let cacheIsExpired = Date() > timestamp.addingTimeInterval(60 * 60 * 24 * 7)
                if cacheIsExpired {
                    // TODO: Refactor
                    feedStore.deleteCachedFeed { deletionError in
                        if let deletionError {
                            completion(.failure(deletionError))
                        } else {
                            completion(.success(nil))
                        }
                    }
                } else {
                    completion(.success(nil))
                }
                
            case .failure(let error): completion(.failure(error))
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

private extension Array where Element == FeedImage {
    var localFeed: [LocalFeedImage] {
        self.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
