import Foundation

internal final class FeedItemsMapper {
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard
            response.isOK,
            let itemsResponse = try? JSONDecoder().decode(FeedItemResponse.self, from: data)
        else {
            throw APIError.invalidData
        }
        
        return itemsResponse.items
    }
}
