import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        
        let initialViewController: UIViewController
        
        if UserDefaults.standard.bool(forKey: UserDefaultsKey.didShowOnboarding) {
            initialViewController = TabBarController()
        } else {
            initialViewController = OnboardingViewController(
                transitionStyle: .scroll,
                navigationOrientation: .horizontal
            )
        }
        
        window.rootViewController = initialViewController
        window.makeKeyAndVisible()
        
        self.window = window
    }
}
