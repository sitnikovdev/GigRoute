import XCTest
@testable import GigRoute

final class ObservableTests: XCTestCase {

    func test_bind_firesImmediatelyWithCurrentValue() {
        let observable = Observable(1)
        var received: [Int] = []

        observable.bind { received.append($0) }

        XCTAssertEqual(received, [1])
    }

    func test_settingValue_notifiesObserver() {
        let observable = Observable("idle")
        var received: [String] = []
        observable.bind { received.append($0) }

        observable.value = "loading"
        observable.value = "loaded"

        XCTAssertEqual(received, ["idle", "loading", "loaded"])
    }
}
