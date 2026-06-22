import Foundation

public protocol FeedStore {
    typealias ActionCompletion = (NSError?) -> Void
    
    func deleteCachedFeed(completion: @escaping ActionCompletion)
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping ActionCompletion)
    func retrieve()
}

