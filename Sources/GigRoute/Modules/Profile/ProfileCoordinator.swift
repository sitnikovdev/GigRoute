import UIKit

final class ProfileCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    let navigationController = UINavigationController()

    private let dependencies: AppDependencyContainer

    init(dependencies: AppDependencyContainer) {
        self.dependencies = dependencies
    }

    @MainActor func start() {
        let viewModel = ProfileViewModel(networkService: dependencies.networkService)
        let viewController = ProfileViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }
}
