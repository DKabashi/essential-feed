import Foundation
import EssentialFeed

final class FeedImageViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    
    private var task: FeedImageDataLoaderTask?

    private let imageLoader: FeedImageDataLoader
    private let feedImage: FeedImage
    private let imageTransformer: (Data) -> Image?
    
    init(feedImage: FeedImage, imageLoader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        self.feedImage = feedImage
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }
    
    var onImageLoad: Observer<Image>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?
    
    var hasLocation: Bool {
        return feedImage.location != nil
    }
    
    var location: String? {
        return feedImage.location
    }
    
    var description: String? {
        return feedImage.description
    }
    
    func loadImageData() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)

        task = imageLoader.loadImageData(from: feedImage.url) { [weak self] result in
            self?.handle(loadImageResult: result)
        }
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
    
    private func handle(loadImageResult result: FeedImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(imageTransformer) {
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoadStateChange?(true)
        }
        
        onImageLoadingStateChange?(false)
    }
}
