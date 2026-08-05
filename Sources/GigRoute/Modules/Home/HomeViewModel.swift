import Foundation

final class HomeViewModel: BaseViewModel {

    let state: Observable<ViewState<String>> = Observable(.idle)

    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func onViewDidLoad() {
        // Real content lands in M1 (greeting, slot status, schedule, wallet).
        // For M0 this only proves the ViewModel -> Observable -> ViewController
        // binding works end to end.
        state.value = .loaded("Главная")
    }
}
