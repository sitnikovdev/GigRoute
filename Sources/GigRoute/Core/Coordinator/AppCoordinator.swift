import UIKit

/// The single entry point for the app's navigation tree. Owns the window
/// and decides what the root flow is (currently always the tab bar).
final class AppCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    // AppCoordinator doesn't push anything itself; it only hosts the tab bar.
    // The property exists to satisfy the protocol and to make each tab's
    // navigationController reachable via its own coordinator.
    let navigationController: UINavigationController = UINavigationController()

    private let window: UIWindow
    private let dependencies: AppDependencyContainer

    init(window: UIWindow, dependencies: AppDependencyContainer) {
        self.window = window
        self.dependencies = dependencies
    }

    func start() {
        let tabBarCoordinator = TabBarCoordinator(dependencies: dependencies)
        addChild(tabBarCoordinator)
        tabBarCoordinator.start()

        window.rootViewController = tabBarCoordinator.tabBarController
        window.makeKeyAndVisible()
    }
}
