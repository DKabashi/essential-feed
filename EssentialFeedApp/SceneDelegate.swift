import UIKit
import EssentialFeediOS
import EssentialFeed

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)
        
        let client = URLSessionHTTPClient()
        let remoteFeedLoader = RemoteFeedLoader(url: serverURL(), client: client)

        let vc = FeedUIComposer.composeWith(feedLoader: remoteFeedLoader, imageLoader: URLSessionFeedImageDataLoader())
        window.rootViewController = vc
        window.makeKeyAndVisible()
        
        self.window = window
    }

    private func serverURL() -> URL {
        return URL(
            string:
                "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed"
        )!
    }
}

private final class URLSessionFeedImageDataLoader: FeedImageDataLoader {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct InvalidDataError: Error {}
    private struct Task: FeedImageDataLoaderTask {
        let wrapped: URLSessionDataTask
        
        func cancel() {
            wrapped.cancel()
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = session.dataTask(with: url) { data, response, error in
            completion(Result {
                if let error = error {
                    throw error
                }
                
                guard
                    let data,
                    let response = response as? HTTPURLResponse,
                    (200..<300).contains(response.statusCode)
                else {
                    throw InvalidDataError()
                }
                
                return data
            })
        }
        task.resume()
        return Task(wrapped: task)
    }
}
