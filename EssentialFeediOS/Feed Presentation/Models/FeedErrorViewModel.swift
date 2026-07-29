import Foundation

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        return .init(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        return .init(message: message)
    }
}
