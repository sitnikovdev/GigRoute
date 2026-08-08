import UIKit
import SnapKit


final class WalletCardView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Кошелек"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = AppColors.primaryText
        return label
    }()
    
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.text = "₽ 12 450"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = AppColors.primaryText
        return label
    }()
    
    private let bonusLabel: UILabel = {
        let label = UILabel()
        label.text = "⭐ 120 бонусов"
        label.font = .systemFont(ofSize: 14, weight: .medium)
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

    func configure(with state: WalletViewState) {
        balanceLabel.text = state.balance
        bonusLabel.text = state.bonusPoints
    }
    
    
    private func setupViews() {
        addSubview(titleLabel)
        addSubview(balanceLabel)
        addSubview(bonusLabel)
    }
    
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }
        
        balanceLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalTo(titleLabel)
            make.bottom.equalToSuperview().inset(16)
        }
        
        bonusLabel.snp.makeConstraints { make in
            make.centerY.equalTo(balanceLabel)
            make.trailing.equalTo(titleLabel)
        }
        
    }
}
