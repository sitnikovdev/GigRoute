import UIKit
import SnapKit

final class OrdersViewController: BaseViewController {

    private let viewModel: OrdersViewModel

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = AppColors.primaryText
        return label
    }()

    init(viewModel: OrdersViewModel) {
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
        view.addSubview(titleLabel)
    }

    override func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }

    override func bindViewModel() {
        viewModel.state.bind { [weak self] state in
            switch state {
            case .idle, .loading:
                self?.titleLabel.text = "Загрузка..."
            case .loaded(let text):
                self?.titleLabel.text = text
            case .error(let message):
                self?.titleLabel.text = message
            }
        }
    }
}
