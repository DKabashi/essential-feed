import Foundation

public protocol FeedStore {
    typealias ActionCompletion = (NSError?) -> Void
    
    func deleteCachedFeed(completion: @escaping ActionCompletion)
    func insertItems(_ items: [FeedItem], timestamp: Date, completion: @escaping ActionCompletion)
}

