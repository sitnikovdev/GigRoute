import Foundation

/// Minimal bindable box. Keeps MVVM binding dependency-free (no Combine/Rx
/// required), while still being easy to swap for Combine's @Published later
/// if the project needs it.
final class Observable<Value> {

    private var observer: ((Value) -> Void)?

    var value: Value {
        didSet { observer?(value) }
    }

    init(_ value: Value) {
        self.value = value
    }

    /// Subscribes to changes. Fires immediately with the current value,
    /// mirroring the common "bind and get current state" UIKit pattern.
    func bind(_ observer: @escaping (Value) -> Void) {
        self.observer = observer
        observer(value)
    }
}
