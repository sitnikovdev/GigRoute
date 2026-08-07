import Foundation

@MainActor
final class HomeViewModel: BaseViewModel {

    /// "Добрый вечер, Олег" once the user has loaded, greeting-only text
    /// while loading/on error.
    let greeting: Observable<String> = Observable("")

    /// Title for the slot toggle button, kept in sync with `SlotStateStore`.
    let slotButtonTitle: Observable<String> = Observable("")

    /// Mirrors `SlotStateStore.isOnSlot` so the view can restyle the button
    /// (e.g. filled vs outlined) without reaching into the store directly.
    let isOnSlot: Observable<Bool> = Observable(false)

    private let userService: UserService
    private let slotStateStore: SlotStateStore

    init(userService: UserService, slotStateStore: SlotStateStore) {
        self.userService = userService
        self.slotStateStore = slotStateStore
    }

    func onViewDidLoad() {
        observeSlotState()
        loadUser()
    }

    func slotButtonTapped() {
        slotStateStore.toggle()
    }

    private func observeSlotState() {
        slotStateStore.isOnSlot.bind { [weak self] isOnSlot in
            self?.isOnSlot.value = isOnSlot
            self?.slotButtonTitle.value = isOnSlot ? "Уйти со слота" : "Выйти на слот"
        }
    }

    private func loadUser() {
        Task { [weak self] in
            guard let self else { return }
            let result = await userService.fetchCurrentUser()
            switch result {
            case .success(let user):
                self.greeting.value = "\(Self.timeOfDayGreeting()), \(user.name)"
            case .failure:
                self.greeting.value = Self.timeOfDayGreeting()
            }
        }
    }

    private static func timeOfDayGreeting(hour: Int = Calendar.current.component(.hour, from: Date())) -> String {
        switch hour {
        case 5..<12: return "Доброе утро"
        case 12..<18: return "Добрый день"
        case 18..<23: return "Добрый вечер"
        default: return "Доброй ночи"
        }
    }
}
