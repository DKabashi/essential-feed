import Foundation

public protocol FeedStore {
    // TODO: Refactor to use insert and deletion completion
    typealias ActionCompletion = (NSError?) -> Void
    typealias RetriveCompletion = (Result<(localItems: [LocalFeedImage], timestamp: Date), NSError>) -> Void
    
    func deleteCachedFeed(completion: @escaping ActionCompletion)
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping ActionCompletion)
    func retrieve(completion: @escaping RetriveCompletion)
}

