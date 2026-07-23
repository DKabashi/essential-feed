import Foundation
import EssentialFeed

protocol FeedImageView {
    associatedtype Image

    func display(_ model: FeedImageViewModel<Image>)
}

struct FeedImageViewModel<Image> {
    let isLoading: Bool
    let image: Image?
    let shouldRetry: Bool
    let location: String?
    let description: String?
    
    var hasLocation: Bool {
        return location != nil
    }
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?
    
    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }

    func didStartLoadingImage(model: FeedImage) {
        view.display(
            FeedImageViewModel(
                isLoading: true,
                image: nil,
                shouldRetry: false,
                location: model.location,
                description: model.description
            )
        )
    }
    
    private struct ImageDataTransformationError: Error {}

    func didFinishLoadingImage(with data: Data, model: FeedImage) {
        guard let image = imageTransformer(data) else {
            didFinishLoadingImageWithError(ImageDataTransformationError(), model: model)
            return
        }
        view.display(
            FeedImageViewModel(
                isLoading: false,
                image: image,
                shouldRetry: false,
                location: model.location,
                description: model.description
            )
        )
    }
    
    func didFinishLoadingImageWithError(_ error: Error, model: FeedImage) {
        view.display(
            FeedImageViewModel(
                isLoading: false,
                image: nil,
                shouldRetry: true,
                location: model.location,
                description: model.description
            )
        )
    }
}
