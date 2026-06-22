import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    private var deletionCompletion: ActionCompletion?
    private var insertionCompletion: ActionCompletion?
    private var retrieveCompletion: ActionCompletion?
    
    private(set) var receivedMessages = [FeedStoreAction]()
    
    enum FeedStoreAction: Equatable {
        case deleteCachedFeed
        case insert(items: [LocalFeedImage], timestamp: Date)
        case retrieve
    }
    
    private(set) var receivedItems = [(timestamp: Date, localItems: [LocalFeedImage])]()
        
    func deleteCachedFeed(completion: @escaping ActionCompletion) {
        receivedMessages.append(.deleteCachedFeed)
        deletionCompletion = completion
    }
    
    func completeCacheDeletion(with error: NSError) {
        deletionCompletion?(error)
    }
    
    func completeCacheDeletionWithSuccess() {
        deletionCompletion?(nil)
    }
    
    func completeInsertion(with error: NSError) {
        insertionCompletion?(error)
    }
    
    func completeCacheInsertionWithSuccess() {
        insertionCompletion?(nil)
    }
    
    func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping ActionCompletion) {
        receivedMessages.append(.insert(items: items, timestamp: timestamp))
        insertionCompletion = completion
    }
    
    func retrieve(completion: @escaping ActionCompletion) {
        receivedMessages.append(.retrieve)
        retrieveCompletion = completion
    }
    
    func completeRetrivalWithError(_ error: NSError) {
        retrieveCompletion?(error)
    }
    
    func completeRetrivalWithFeedData(timestamp: Date, localItems: [LocalFeedImage]) {
        receivedItems.append((timestamp: timestamp, localItems: localItems))
        retrieveCompletion?(nil)
    }
}
