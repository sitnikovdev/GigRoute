import UIKit
import SnapKit

final class HomeViewController: BaseViewController {

    private let viewModel: HomeViewModel

    private let greetingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = AppColors.primaryText
        label.numberOfLines = 2
        return label
    }()

    private let slotButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .white
        configuration.baseForegroundColor = .black
        configuration.cornerStyle = .large
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
        let button = UIButton(configuration: configuration)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return button
    }()

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.onViewDidLoad()
    }

    override func setupViews() {
        view.addSubview(greetingLabel)
        view.addSubview(slotButton)
        slotButton.addTarget(self, action: #selector(slotButtonTapped), for: .touchUpInside)
    }

    override func setupConstraints() {
        greetingLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        slotButton.snp.makeConstraints { make in
            make.top.equalTo(greetingLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }
    }

    override func bindViewModel() {
        viewModel.greeting.bind { [weak self] text in
            self?.greetingLabel.text = text
        }

        viewModel.slotButtonTitle.bind { [weak self] title in
            self?.slotButton.configuration?.title = title
        }
    }

    @objc
    private func slotButtonTapped() {
        viewModel.slotButtonTapped()
    }
}
