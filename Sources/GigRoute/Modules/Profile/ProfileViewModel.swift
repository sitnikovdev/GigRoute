import Foundation

final class ProfileViewModel: BaseViewModel {

    let state: Observable<ViewState<String>> = Observable(.idle)

    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func onViewDidLoad() {
        // Stats card + settings list lands in M4.
        state.value = .loaded("Профиль")
    }
}
