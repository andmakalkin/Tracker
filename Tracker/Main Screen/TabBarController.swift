import UIKit

final class TabBarController: UITabBarController {
    
    // MARK: - Child View Controllers
    private let trackersViewController = TrackersViewController(
        storage: Storage(),
        dataProvider: TabBarController.makeDataProvider()
    )
    
    private let statisticsViewController = StatisticsViewController()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBar()
        setupTabBarItems()
        
        viewControllers = [trackersViewController, statisticsViewController]
    }
    
    // MARK: - UI Setup
    private func setupTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = UIColor(white: 0, alpha: 0.3)
        
        let itemAppearance = appearance.stackedLayoutAppearance
        itemAppearance.selected.iconColor = .ypBlue
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.ypBlue]
        itemAppearance.normal.iconColor = .ypGray
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.ypGray]
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        tabBar.isTranslucent = true
        tabBar.tintColor = .clear
        tabBar.backgroundColor = .clear
    }
    
    private func setupTabBarItems() {
        trackersViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(resource: .tabBarTrackersActive),
            selectedImage: nil
        )
        
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(resource: .tabBarStatisticsActive),
            selectedImage: nil
        )
    }
    
    // MARK: - Helpers
    private static func makeDataProvider() -> TrackersDataProviderProtocol {
        do {
            return try TrackersDataProvider()
        } catch {
            fatalError("❌ [TabBarController] makeDataProvider: не удалось создать TrackersDataProvider: \(error)")
        }
    }
}
