import UIKit

/// Base for every screen in the app. Applies the shared background/theme
/// and gives subclasses clearly named override points instead of relying
/// on raw `viewDidLoad`. Views are built entirely in code + SnapKit —
/// no Storyboards or XIBs anywhere in the project.
class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupViews()
        setupConstraints()
        bindViewModel()
    }

    /// Add subviews to `view` here.
    func setupViews() {}

    /// Add SnapKit constraints here. Kept separate from `setupViews` so
    /// subclasses reading the file top-to-bottom see "what" before "where".
    func setupConstraints() {}

    /// Bind to the view model's `Observable` properties here.
    func bindViewModel() {}
}
