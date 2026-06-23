import Foundation

public final class LocalFeedLoader {
    private var feedStore: FeedStore
    private var createTimestamp: () -> Date
    private let calendar = Calendar(identifier: .gregorian)
    
    public typealias SaveResult = NSError?
    public typealias LoadResult = LoadFeedResult
    
    public let validExpireDays: Int = 7
    
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
            guard self != nil else { return }
            switch result {
            case .success((let localFeedItems, _)):
                completion(.success(localFeedItems.feedImages))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func validateCache() {
        feedStore.retrieve { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure:
                deleteExpiredCache { _ in }
            case .success((_, let timestamp)) where isExpired(timestamp: timestamp):
                deleteExpiredCache { _ in }
            case .success:
                break
            }
        }
    }
    
    private func deleteExpiredCache(completion: @escaping (LoadResult) -> Void) {
        feedStore.deleteCachedFeed { deletionError in
            if let deletionError {
                completion(.failure(deletionError))
            } else {
                completion(.success([]))
            }
        }
    }
    
    private func isExpired(timestamp: Date) -> Bool {
        guard let expiredDate = calendar.date(byAdding: .day, value: validExpireDays, to: timestamp) else {
            return true
        }
        return Date() > expiredDate
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

private extension Array where Element == LocalFeedImage {
    var feedImages: [FeedImage] {
        self.map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
