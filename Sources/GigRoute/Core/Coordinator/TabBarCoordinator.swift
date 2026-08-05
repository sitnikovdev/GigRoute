import UIKit

/// Owns the UITabBarController and starts one child coordinator per tab.
/// Each tab keeps its own UINavigationController so pushes inside a tab
/// don't leak into the others.
final class TabBarCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController = UINavigationController()

    let tabBarController = UITabBarController()

    private let dependencies: AppDependencyContainer

    init(dependencies: AppDependencyContainer) {
        self.dependencies = dependencies
    }

    func start() {
        let home = makeTab(
            coordinator: HomeCoordinator(dependencies: dependencies),
            title: "Главная",
            image: UIImage(systemName: "house")
        )
        let orders = makeTab(
            coordinator: OrdersCoordinator(dependencies: dependencies),
            title: "Заказы",
            image: UIImage(systemName: "paperplane")
        )
        let messages = makeTab(
            coordinator: MessagesCoordinator(dependencies: dependencies),
            title: "Сообщения",
            image: UIImage(systemName: "message")
        )
        let profile = makeTab(
            coordinator: ProfileCoordinator(dependencies: dependencies),
            title: "Профиль",
            image: UIImage(systemName: "person.crop.circle")
        )

        tabBarController.viewControllers = [home, orders, messages, profile]
        tabBarController.tabBar.tintColor = AppColors.accent
        tabBarController.tabBar.barTintColor = AppColors.background
        tabBarController.tabBar.backgroundColor = AppColors.background
    }

    /// Starts a tab's coordinator and wraps its navigation controller
    /// as a UITabBarController item.
    private func makeTab(
        coordinator: Coordinator,
        title: String,
        image: UIImage?
    ) -> UINavigationController {
        addChild(coordinator)
        coordinator.start()

        let nav = coordinator.navigationController
        nav.tabBarItem = UITabBarItem(title: title, image: image, selectedImage: nil)
        nav.navigationBar.prefersLargeTitles = false
        return nav
    }
}
