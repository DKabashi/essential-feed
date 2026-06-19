import Foundation

public final class LocalFeedLoader {
    private var feedStore: FeedStore
    private var createTimestamp: () -> Date
    
    public init(store: FeedStore, createTimestamp: @escaping () -> Date) {
        feedStore = store
        self.createTimestamp = createTimestamp
    }
    
    public func save(items: [FeedItem], completion: @escaping (NSError?) -> Void) {
        feedStore.deleteCachedFeed { [weak self] deletionError in
            guard let self else { return }
            if let error = deletionError {
                completion(error)
            } else {
                cache(items: items, completion: completion)
            }
        }
    }
    
    private func cache(items: [FeedItem], completion: @escaping (NSError?) -> Void) {
        feedStore.insertItems(items, timestamp: createTimestamp(), completion: { [weak self] insertionError in
            guard self != nil else { return }
            
            completion(insertionError)
        })
    }
}
