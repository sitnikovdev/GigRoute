import Foundation

/// Single source of truth for whether the courier is currently on a slot.
/// Shared instance lives in `AppDependencyContainer` so Home (M1) and
/// Orders (M2) read/write the same state.
///
/// This is intentionally minimal: in-memory only, no persistence, no
/// network sync, no offline handling. M6 ("Slot/Location State") extends
/// this same interface with UserDefaults/Keychain persistence and
/// error handling — nothing that binds to `isOnSlot` today should need to
/// change when that lands.
final class SlotStateStore {
    let isOnSlot: Observable<Bool> = Observable(false)

    func toggle() {
        isOnSlot.value.toggle()
    }
}
