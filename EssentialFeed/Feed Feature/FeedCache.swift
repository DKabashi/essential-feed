import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(feed: [FeedImage], completion: @escaping (Result) -> Void)
}
