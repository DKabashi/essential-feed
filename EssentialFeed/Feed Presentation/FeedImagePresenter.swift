import Foundation

public final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let imageView: View
    private let loadingView: LoadingView
    private let retryView: RetryView
    private let imageTransformer: (Data) -> Image?
    
    public init(imageView: View, loadingView: LoadingView, retryView: RetryView, imageTransformer: @escaping (Data) -> Image?) {
        self.imageView = imageView
        self.loadingView = loadingView
        self.retryView = retryView
        self.imageTransformer = imageTransformer
    }
    
    public func didStartLoadingImage(model: FeedImage) {
        imageView.display(FeedImageViewModel(image: nil, location: model.location, description: model.description))
        retryView.display(RetryViewModel(shouldRetry: false))
        loadingView.display(LoadingViewModel(isLoading: true))
    }
    
    private struct ImageDataTransformationError: Error {}

    public func didFinishLoadingImage(with data: Data, model: FeedImage) {
        guard let image = imageTransformer(data) else {
            didFinishLoadingImageWithError(ImageDataTransformationError())
            return
        }
        loadingView.display(LoadingViewModel(isLoading: false))
        retryView.display(RetryViewModel(shouldRetry: false))
        imageView.display(
            FeedImageViewModel(
                image: image,
                location: model.location,
                description: model.description
            )
        )
    }

    public func didFinishLoadingImageWithError(_ error: Error) {
        loadingView.display(LoadingViewModel(isLoading: false))
        retryView.display(RetryViewModel(shouldRetry: true))
    }
}
