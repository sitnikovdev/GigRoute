import UIKit
import SnapKit


final class ScheduleCardView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Ближайший слот"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = AppColors.primaryText
        return label
    }()


    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Сегодня · 10:00–14:00"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = AppColors.primaryText
        return label
    }()


    private let cityLabel: UILabel = {
        let label = UILabel()
        label.text = "Москва"
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
        fatalError("init(coder:) has not been implementd")
    }

    func configure(with state: ScheduleViewState) {
        dateLabel.text = state.date
        cityLabel.text = state.city
    }


    private func setupViews() {
        addSubview(titleLabel)
        addSubview(dateLabel)
        addSubview(cityLabel)
    }


    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in 
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        dateLabel.snp.makeConstraints {make  in 
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(titleLabel)
        }

        cityLabel.snp.makeConstraints { make in 
            make.top.equalTo(dateLabel.snp.bottom).offset(4)
            make.leading.trailing.equalTo(titleLabel)
            make.bottom.equalToSuperview().inset(16)
        }
    }
}
