import Foundation

internal final class FeedCachePolicy {
    private static let calendar = Calendar(identifier: .gregorian)
    public static let validExpireDays: Int = 7
    
    private init() { }
    
    internal static func isExpired(timestamp: Date, against date: Date) -> Bool {
        guard let expiredDate = calendar.date(byAdding: .day, value: validExpireDays, to: timestamp) else {
            return true
        }
        return date >= expiredDate
    }
}
