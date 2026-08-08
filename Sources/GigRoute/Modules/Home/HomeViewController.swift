import UIKit
import SnapKit

final class HomeViewController: BaseViewController {

    private let viewModel: HomeViewModel

    private let previewOffers = [
        (
            title: "Специальное предложение",
            subtitle: "Заработайте больше на следующем слоте"
        ),
        (
             title: "Больше заказов",
             subtitle: "Доступны новые заказы рядом с вами"
        ),
        (
            title: "Повышенный заработок",
            subtitle: "Получите бонус за активность"
        )
    ]

    private let scrollView = UIScrollView()

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()

    private let greetingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = AppColors.primaryText
        label.numberOfLines = 2
        return label
    }()

    private let mapCardView = HomeMapCardView()
    private let scheduleCardView = ScheduleCardView()
    private let walletCardView = WalletCardView()

    private let offersTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Для вас"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = AppColors.primaryText
        return label
    }()

    private lazy var offersCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: makeOffersLayout()
        )

        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never

        collectionView.register(
            OfferCollectionViewCell.self,
            forCellWithReuseIdentifier: OfferCollectionViewCell.reuseIdentifier
        )

        collectionView.dataSource = self

        return collectionView
    }()

    private let slotButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .white
        configuration.baseForegroundColor = .black
        configuration.cornerStyle = .large
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 16,
            leading: 20,
            bottom: 16,
            trailing: 20
        )

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
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        contentStackView.addArrangedSubview(greetingLabel)
        contentStackView.addArrangedSubview(mapCardView)
        contentStackView.addArrangedSubview(scheduleCardView)
        contentStackView.addArrangedSubview(walletCardView)
        contentStackView.addArrangedSubview(offersTitleLabel)
        contentStackView.addArrangedSubview(offersCollectionView)
        contentStackView.addArrangedSubview(slotButton)

        slotButton.addTarget(
            self,
            action: #selector(slotButtonTapped),
            for: .touchUpInside
        )
    }

    override func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.width.equalTo(scrollView.frameLayoutGuide).offset(-40)
        }

        mapCardView.snp.makeConstraints { make in
            make.height.equalTo(180)
        }

        offersCollectionView.snp.makeConstraints { make in
            make.height.equalTo(130)
        }

        slotButton.snp.makeConstraints { make in
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

        viewModel.schedule.bind { [weak self] state in
            self?.scheduleCardView.configure(with: state)
        }

        viewModel.wallet.bind { [weak self] state in
            self?.walletCardView.configure(with: state)
        }
    }

    private func makeOffersLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(280),
            heightDimension: .absolute(130)
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.orthogonalScrollingBehavior = .continuous

        return UICollectionViewCompositionalLayout(section: section)
    }

    @objc
    private func slotButtonTapped() {
        viewModel.slotButtonTapped()
    }
}

extension HomeViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        previewOffers.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: OfferCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? OfferCollectionViewCell else {
            return UICollectionViewCell()
        }

        let offer = previewOffers[indexPath.item]

        cell.configure(
            title: offer.title,
            subtitle: offer.subtitle
        )
        return cell
    }
}
