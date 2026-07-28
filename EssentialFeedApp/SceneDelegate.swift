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

        let vc = FeedUIComposer.composeWith(feedLoader: remoteFeedLoader, imageLoader: ImageLoaderPlaceholder())
        window.rootViewController = vc
        window.makeKeyAndVisible()
        
        self.window = window
    }
    
    final class ImageLoaderPlaceholder: FeedImageDataLoader {
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> any FeedImageDataLoaderTask {
            return DummyTask()
        }
    }
    
    struct DummyTask: FeedImageDataLoaderTask {
        func cancel() {
        }
    }
    
    private func serverURL() -> URL {
        return URL(
            string:
                "https://essentialdeveloper.com/feed-case-study/test-api/feed"
        )!
    }
}

