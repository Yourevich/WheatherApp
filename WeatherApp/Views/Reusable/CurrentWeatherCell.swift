//
//  CurrentWeatherCell.swift
//  WeatherApp
//
//  Created by Илья Зорин on 14.05.2025.
//

import UIKit

final class CurrentWeatherCell: UICollectionViewCell {
    static let reuseIdentifier = "CurrentWeatherCell"

    private let cityLabel = UILabel()
    private let timeLabel = UILabel()
    private let iconImageView = UIImageView()
    private let tempLabel = UILabel()
    private let feelsLikeLabel = UILabel()
    private let conditionLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        cityLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        timeLabel.font = .systemFont(ofSize: 14)
        tempLabel.font = .systemFont(ofSize: 64, weight: .thin)
        feelsLikeLabel.font = .systemFont(ofSize: 14)
        conditionLabel.font = .systemFont(ofSize: 18)
        conditionLabel.numberOfLines = 0
        conditionLabel.lineBreakMode = .byWordWrapping

        iconImageView.contentMode = .scaleAspectFit

        [cityLabel, timeLabel, iconImageView, tempLabel, feelsLikeLabel, conditionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cityLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            cityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            timeLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: cityLabel.leadingAnchor),

            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            iconImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            iconImageView.widthAnchor.constraint(equalToConstant: 64),
            iconImageView.heightAnchor.constraint(equalToConstant: 64),

            tempLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 16),
            tempLabel.leadingAnchor.constraint(equalTo: cityLabel.leadingAnchor),

            feelsLikeLabel.topAnchor.constraint(equalTo: tempLabel.bottomAnchor, constant: 4),
            feelsLikeLabel.leadingAnchor.constraint(equalTo: cityLabel.leadingAnchor),

            conditionLabel.topAnchor.constraint(equalTo: feelsLikeLabel.bottomAnchor, constant: 8),
            conditionLabel.leadingAnchor.constraint(equalTo: cityLabel.leadingAnchor),
            conditionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            conditionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    func configure(with data: CurrentWeatherResponse) {
        cityLabel.text = data.location.name
        timeLabel.text = data.location.localtime
        tempLabel.text = "\(Int(data.current.tempC))°"
        feelsLikeLabel.text = "Ощущается как \(Int(data.current.feelslikeC))°"
        conditionLabel.text = data.current.condition.text

        let iconURL = URL(string: "https:" + data.current.condition.icon)
        URLSession.shared.dataTask(with: iconURL!) { [weak self] data, _, _ in
            guard let data = data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.iconImageView.image = img
            }
        }.resume()
    }
}
