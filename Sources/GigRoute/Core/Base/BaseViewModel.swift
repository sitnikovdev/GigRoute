import Foundation

/// Generic screen state most view models will expose in some form.
/// Individual view models are free to carry richer state alongside this
/// (e.g. HomeViewModel exposes `state` plus specific fields), but sharing
/// this enum keeps loading/error handling consistent across modules.
enum ViewState<Content> {
    case idle
    case loading
    case loaded(Content)
    case error(String)
}

/// Every view model exposes an `onAppear`-style entry point view controllers
/// call from `viewDidLoad`/`viewWillAppear`. Kept minimal on purpose —
/// concrete view models add their own `Observable` properties for the UI to
/// bind to.
protocol BaseViewModel: AnyObject {
    func onViewDidLoad()
}
