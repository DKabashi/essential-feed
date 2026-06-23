import Foundation
import EssentialFeed

func uniqueFeedItem() -> FeedImage {
    return FeedImage(id: UUID(), url: anyURL())
}

func uniqueLocalFeedItem() -> LocalFeedImage {
    return LocalFeedImage(id: UUID(), url: anyURL())
}

extension Date {
    func minusFeedCacheMaxAge() -> Date {
        let validExpireDays = 7
        return addDays(-validExpireDays)
    }
    
    func addDays(_ days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func addSeconds(_ seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
