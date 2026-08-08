import UIKit

final class HomeCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    let navigationController = UINavigationController()

    private let dependencies: AppDependencyContainer

    init(dependencies: AppDependencyContainer) {
        self.dependencies = dependencies
    }

    @MainActor func start() {
        let viewModel = HomeViewModel(
            userService: dependencies.userService,
            slotStateStore: dependencies.slotStateStore,
            slotService: dependencies.slotService
        )
        let viewController = HomeViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }
}
