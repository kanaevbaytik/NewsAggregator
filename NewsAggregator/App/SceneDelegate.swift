
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        let tabBarController = UITabBarController()

        let newsListVC = NewsListViewController()
        newsListVC.tabBarItem = UITabBarItem(title: "Все новости", image: UIImage(systemName: "newspaper"), tag: 0)

        let favoritesVC = FavoritesViewController()
        favoritesVC.tabBarItem = UITabBarItem(title: "Избранное", image: UIImage(systemName: "star"), tag: 1)

        tabBarController.viewControllers = [
            UINavigationController(rootViewController: newsListVC),
            UINavigationController(rootViewController: favoritesVC)
        ]

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
}

