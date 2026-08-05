import Foundation

final class MessagesViewModel: BaseViewModel {

    let state: Observable<ViewState<String>> = Observable(.idle)

    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func onViewDidLoad() {
        // Banner carousel + message list lands in M3.
        state.value = .loaded("Сообщения")
    }
}
