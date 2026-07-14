import Foundation
import EssentialFeed
import EssentialFeediOS

extension FeedViewControllerTests {
    class FeedLoaderSpy: FeedLoader, FeedImageDataLoader {
        
        // MARK: Feed Loader
        private var feedRequests = [(FeedLoader.Result) -> Void]()
        
        var loadFeedCallCount: Int {
            feedRequests.count
        }
        
        func loadFeed(completion: @escaping (FeedLoader.Result) -> Void) {
            feedRequests.append(completion)
        }
        
        func completeFeedLoading(with images: [FeedImage] = [], at index: Int) {
            feedRequests[index](.success(images))
        }
        
        func completeFeedLoadingWithError(at index: Int) {
            feedRequests[index](.failure(anyNSError()))
        }
        
        // MARK: Image Data Loader
        typealias LoadImageCompletion = (FeedImageDataLoader.Result) -> Void
        
        private(set) var loadImageRequests = [(url: URL, completion: LoadImageCompletion)]()
        private(set) var cancelledImageURLs = [URL]()
        
        var loadedImageRequestURLs: [URL] {
            return loadImageRequests.map { $0.url }
        }
        
        private struct FeedImageDataLoaderTaskSpy: FeedImageDataLoaderTask {
            let cancelAction: () -> Void
            
            func cancel() {
                cancelAction()
            }
        }
        
        func loadImageData(from url: URL, completion: @escaping LoadImageCompletion) -> FeedImageDataLoaderTask {
            loadImageRequests.append((url: url, completion: completion))
            
            return FeedImageDataLoaderTaskSpy { [weak self] in
                self?.cancelledImageURLs.append(url)
            }
        }
        
        func completeImageDataLoadingWithSuccess(with data: Data? = nil, at index: Int) {
            loadImageRequests[index].completion(.success(data ?? anyData()))
        }
        
        func completeImageDataLoadingWithFailure(at index: Int) {
            loadImageRequests[index].completion(.failure(anyNSError()))
        }
    }
}
