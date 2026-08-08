import Foundation

/// Deliberately simple: a plain struct handing out shared services.
/// No DI framework — coordinators receive this container and pass the
/// specific services each view model needs. Swap for something heavier
/// only if/when the number of services makes that worthwhile.
final class AppDependencyContainer {
    let networkService: NetworkService
    let userService: UserService
    let slotStateStore: SlotStateStore
    let slotService: SlotService

    init() {
        // Placeholder base URL until a real backend exists.
        let baseURL = URL(string: "https://api.gigroute.example.com")!

        self.networkService = URLSessionNetworkService(baseURL: baseURL)
        self.userService = LocalUserService()
        self.slotStateStore = SlotStateStore()
        self.slotService = LocalSlotService()
    }
}
