import Foundation

public class CodableFeedStore: FeedStore {
    
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var toLocalFeed: [LocalFeedImage] {
            feed.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
        }
    }
    
    private struct CodableFeedImage: Codable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let url: URL
        
        init(from image: LocalFeedImage) {
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.url = image.url
        }
    }

    private var storeURL: URL
    // TODO: Why does this queue guarantee things run serially and .global doesnt
    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)queue", qos: .userInitiated, attributes: .concurrent)
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }

    public func retrieve(completion: @escaping RetriveCompletion) {
        let storeURL = self.storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.empty)
            }
            
            do {
                let decoder = JSONDecoder()
                let decodedCache = try decoder.decode(Cache.self, from: data)
                completion(.success(decodedCache.toLocalFeed, decodedCache.timestamp))
            } catch {
                completion(.failure(error as NSError))
            }
        }
    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            do {
                let encoder = JSONEncoder()
                let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
                let encodedData = try encoder.encode(cache)
                try encodedData.write(to: storeURL)
                completion(nil)
            } catch {
                completion(error as NSError)
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeleteCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path()) else {
                completion(nil)
                return
            }
            
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            } catch {
                completion(error as NSError)
            }
        }
    }
}

