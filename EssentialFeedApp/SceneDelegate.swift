import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        let vc = ViewController()
        
        let window = UIWindow(windowScene: scene)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        
        self.window = window
    }
}

