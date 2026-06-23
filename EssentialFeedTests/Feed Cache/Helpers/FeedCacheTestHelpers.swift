import Foundation
import EssentialFeed

func uniqueFeedItem() -> FeedImage {
    return FeedImage(id: UUID(), url: anyURL())
}

func uniqueLocalFeedItem() -> LocalFeedImage {
    return LocalFeedImage(id: UUID(), url: anyURL())
}

var validExpireDays: Int = 7

extension Date {
    func addDays(_ days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func addSeconds(_ seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
