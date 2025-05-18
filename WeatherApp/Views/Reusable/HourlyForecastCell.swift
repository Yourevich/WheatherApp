//
//  HourlyForecastCell.swift
//  WeatherApp
//
//  Created by Илья Зорин on 14.05.2025.
//

import Foundation

import UIKit

final class HourlyForecastCell: UICollectionViewCell {
    static let reuseIdentifier = "HourlyForecastCell"

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let tempLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
    }

    private func setupViews() {
        contentView.addSubview(timeLabel)
        contentView.addSubview(iconImageView)
        contentView.addSubview(tempLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            iconImageView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 4),
            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),

            tempLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 4),
            tempLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tempLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tempLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with entry: HourlyForecastEntry, isFirstHour: Bool) {
            if isFirstHour {
                timeLabel.text = "Сейчас"
            } else {
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd HH:mm"
                df.locale = Locale(identifier: "ru_RU_POSIX")
                if let entryDate = df.date(from: entry.time) {
                    let timeOnly = DateFormatter()
                    timeOnly.dateFormat = "HH:mm"
                    timeOnly.locale = Locale(identifier: "ru_RU_POSIX")
                    timeLabel.text = timeOnly.string(from: entryDate)
                } else {
                    timeLabel.text = "--:--"
                }
            }

            tempLabel.text = "\(Int(entry.tempC))°"

            loadIcon(from: entry.condition.icon)
        }

        private func loadIcon(from path: String) {
            guard let url = URL(string: "https:" + path) else { return }
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data, let img = UIImage(data: data) else { return }
                DispatchQueue.main.async { self?.iconImageView.image = img }
            }.resume()
        }
}
