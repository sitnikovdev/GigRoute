import Foundation

@MainActor
final class HomeViewModel: BaseViewModel {

    let schedule: Observable<ScheduleViewState>

    let wallet: Observable<WalletViewState> = Observable(
        WalletViewState(
            balance: "",
            bonusPoints: ""
        )
    )


    private let userService: UserService
    private let slotStateStore: SlotStateStore
    private let slotService: SlotService
    private let walletService: WalletService

    let greeting: Observable<String> = Observable("")

    let slotButtonTitle: Observable<String> = Observable("")

    /// Mirrors `SlotStateStore.isOnSlot` so the view can restyle the button
    /// (e.g. filled vs outlined) without reaching into the store directly.
    let isOnSlot: Observable<Bool> = Observable(false)


    init(userService: UserService,
         slotStateStore: SlotStateStore,
         slotService: SlotService,
         walletService: WalletService
         ) {
        self.userService = userService
        self.slotStateStore = slotStateStore
        self.slotService = slotService
        self.walletService = walletService
        self.schedule = Observable(
            ScheduleViewState(
                date: "",
                city: ""
            )
        )
    }

    func onViewDidLoad() {
        observeSlotState()
        loadUser()
        loadSchedule()
        loadWallet()
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

    private func loadWallet() {
        Task { [weak self] in
            guard let self else { return }

            let result = await walletService.fetchWallet()

            switch result {
            case .success(let wallet):
                self.wallet.value = WalletViewState(
                    balance: Self.formatBalance(wallet.balance),
                    bonusPoints: "⭐ \(wallet.bonusPoints) бонусов"
                )

            case .failure:
                self.wallet.value = WalletViewState(
                    balance: "Не удалось загрузить",
                    bonusPoints: ""
                )
            }
        }
    }

    private static func formatBalance(_ balance: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0

        let number = balance as NSDecimalNumber

        return "₽ \(formatter.string(from: number) ?? "0")"
    }

    private func loadSchedule() {
        Task {[weak self] in
            guard let self else { return }

        let result = await slotService.fetchNearestSlot()

        switch result {
        case .success(let slot):
                guard let slot else {
                    schedule.value = ScheduleViewState(
                        date: "Нет запланированных слотов",
                        city: ""
                    )

                    return
                }

                schedule.value = ScheduleViewState(
                    date: Self.formatScheduleDate(for: slot),
                    city: slot.city
                )

            case .failure:
                schedule.value = ScheduleViewState(
                    date:  "Не удалось загрузить слот",
                    city:  ""
                )
            }
        }
    }

    private static func formatScheduleDate(for slot: Slot) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "d MMMM"

        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "ru_RU")
        timeFormatter.dateFormat = "HH:mm"

        let date = dateFormatter.string(from: slot.startDate)
        let startTime = timeFormatter.string(from: slot.startDate)
        let endTime = timeFormatter.string(from: slot.endDate)

        return "\(date) · \(startTime)–\(endTime)"
    }



}
