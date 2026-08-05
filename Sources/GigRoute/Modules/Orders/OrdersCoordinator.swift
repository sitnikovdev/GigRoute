import UIKit

final class OrdersCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    let navigationController = UINavigationController()

    private let dependencies: AppDependencyContainer

    init(dependencies: AppDependencyContainer) {
        self.dependencies = dependencies
    }

    func start() {
        let viewModel = OrdersViewModel(networkService: dependencies.networkService)
        let viewController = OrdersViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }
}
