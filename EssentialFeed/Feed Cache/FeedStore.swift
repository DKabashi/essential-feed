import Foundation

public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    typealias RetrivalResult = Result<CachedFeed?, Error>
    typealias InsertionResult = Result<Void, Error>
    typealias DeletionResult = Result<Void, Error>
    
    typealias RetriveCompletion = (RetrivalResult) -> Void
    typealias InsertionCompletion = (InsertionResult) -> Void
    typealias DeleteCompletion = (DeletionResult) -> Void

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
