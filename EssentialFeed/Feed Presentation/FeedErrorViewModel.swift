import Foundation

public struct FeedErrorViewModel {
    public let message: String?
    
    static var noError: FeedErrorViewModel {
        return .init(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
