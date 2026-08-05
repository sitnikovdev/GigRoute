import Foundation

final class OrdersViewModel: BaseViewModel {

    let state: Observable<ViewState<String>> = Observable(.idle)

    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func onViewDidLoad() {
        // Map + slot management lands in M2.
        state.value = .loaded("Заказы")
    }
}
