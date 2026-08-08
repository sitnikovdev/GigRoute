import UIKit
import SnapKit



final class OfferCollectionViewCell: UICollectionViewCell {

  static let reuseIdentifier = "OfferCollectionViewCell"

  private let titleLabel: UILabel = {
      let label = UILabel()
      label.text = "Специальное предложение"
      label.font = .systemFont(ofSize: 16, weight: .bold)
      label.textColor = AppColors.primaryText
      label.numberOfLines = 2
      return label
  }()

  private let subtitleLabel: UILabel = {
    let label = UILabel()
    label.text = "Заработайте больше на следующем слоте"
    label.font = .systemFont(ofSize: 13)
    label.textColor = AppColors.secondaryText
    label.numberOfLines = 2
    return label
  }()

  override init(frame: CGRect) {
      super.init(frame: frame)

      contentView.backgroundColor = AppColors.cardBackground
      contentView.layer.cornerRadius = 16

      setupViews()
      setupConstraints()
  }


    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }

    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }

        subtitleLabel.snp.makeConstraints { make in 
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(titleLabel)
            make.bottom.lessThanOrEqualToSuperview().inset(16)
        }
    }

}
