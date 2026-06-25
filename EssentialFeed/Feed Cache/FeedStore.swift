import Foundation

public protocol FeedStore {
    typealias DeleteCompletion = (NSError?) -> Void
    typealias InsertionCompletion = (NSError?) -> Void
    typealias RetriveCompletion = (RetrieveResult) -> Void
    
    /// The completion handler can be invoked in any thread
    /// Clients are responsible to dispatch to appropriate thread, if needed
    func deleteCachedFeed(completion: @escaping DeleteCompletion)
    
    /// The completion handler can be invoked in any thread
    /// Clients are responsible to dispatch to appropriate thread, if needed
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    
    /// The completion handler can be invoked in any thread
    /// Clients are responsible to dispatch to appropriate thread, if needed
    func retrieve(completion: @escaping RetriveCompletion)
}

public enum RetrieveResult {
    case empty
    case success([LocalFeedImage], Date)
    case failure(NSError)
}

