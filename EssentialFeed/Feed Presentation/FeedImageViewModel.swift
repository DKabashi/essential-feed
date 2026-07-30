import Foundation

public struct FeedImageViewModel<Image> {
    public let image: Image?
    public let location: String?
    public let description: String?
    
    public var hasLocation: Bool {
        return location != nil
    }
}
