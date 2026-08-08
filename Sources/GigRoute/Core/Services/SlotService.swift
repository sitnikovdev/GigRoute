import Foundation 


protocol SlotService {
    func fetchNearestSlot() async -> Result<Slot?, Error>
}


final class LocalSlotService: SlotService {

    func fetchNearestSlot() async -> Result<Slot?, Error> {
        let calendar = Calendar.current
        let startDate = calendar.date(
            bySettingHour: 10,
            minute: 0,
            second: 0,
            of: Date()
        ) ?? Date()

        let endDate = calendar.date(
            byAdding: .hour,
            value: 4,
            to: startDate
        ) ?? startDate

        let slot = Slot(
            id: UUID(),
            startDate: startDate,
            endDate: endDate,
            city: "Москва"
        )

        return .success(slot)
    }
}
