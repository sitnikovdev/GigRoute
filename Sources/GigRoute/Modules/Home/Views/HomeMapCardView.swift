import UIKit
import SnapKit


final class HomeMapCardView: UIView {

  private let mapIconView: UIImageView = {
      let imageView = UIImageView(
          image: UIImage(systemName: "map.fill")
      )
      imageView.tintColor = AppColors.primaryText
      imageView.contentMode = .scaleAspectFit
      return imageView
  }()

  private let titleLabel: UILabel = {
      let label = UILabel()
      label.text = "Ваша текущая позиция"
      label.font = .systemFont(ofSize: 16, weight: .semibold)
      label.textColor = AppColors.primaryText
      return label
  }()

  private let subtitleLabel: UILabel = {
      let label = UILabel()
      label.text = "Карта и заказы"
      label.font = .systemFont(ofSize: 14)
      label.textColor = AppColors.secondaryText
      return label
  }()

  
  override init(frame: CGRect) {
      super.init(frame: frame)
      backgroundColor = AppColors.cardBackground
      layer.cornerRadius = 16

      setupViews()
      setupConstraints()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }


  private func setupViews() {
      
      addSubview(mapIconView)
      addSubview(titleLabel)
      addSubview(subtitleLabel)
  }

  private func setupConstraints() {

      mapIconView.snp.makeConstraints { make in 
          make.center.equalToSuperview()
          make.size.equalTo(40)
      }

      titleLabel.snp.makeConstraints { make in 
          make.leading.equalToSuperview().offset(16)
          make.bottom.equalTo(subtitleLabel.snp.top).offset(-4)
      }

      subtitleLabel.snp.makeConstraints { make in 
          make.leading.equalTo(titleLabel)
          make.bottom.equalToSuperview().inset(16)
      }

  }











}
