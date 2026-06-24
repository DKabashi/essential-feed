import Foundation

public protocol FeedStore {
    typealias DeleteCompletion = (NSError?) -> Void
    typealias InsertionCompletion = (NSError?) -> Void
    typealias RetriveCompletion = (RetrieveResult) -> Void
    
    func deleteCachedFeed(completion: @escaping DeleteCompletion)
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetriveCompletion)
}

public enum RetrieveResult {
    case empty
    case success([LocalFeedImage], Date)
    case failure(NSError)
}

