//
//  DailyForecastCell.swift
//  WeatherApp
//
//  Created by Илья Зорин on 14.05.2025.
//

import Foundation
import UIKit

final class DailyForecastCell: UICollectionViewCell {
    static let reuseIdentifier = "DailyForecastCell"

    private let dayLabel = UILabel()
    private let iconImageView = UIImageView()
    private let minMaxLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true

        dayLabel.font = .systemFont(ofSize: 16, weight: .medium)
        minMaxLabel.font = .systemFont(ofSize: 14)
        iconImageView.contentMode = .scaleAspectFit

        [dayLabel, iconImageView, minMaxLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),

            minMaxLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            minMaxLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with day: ForecastDay) {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.locale = Locale(identifier: "ru_RU_POSIX")
        
        if let forecastDate = df.date(from: day.date) {
            let calendar = Calendar.current
            let today = Date()
            
            if calendar.isDate(forecastDate, inSameDayAs: today) {
                dayLabel.text = "Сегодня"
            } else {
                let wd = DateFormatter()
                wd.locale = Locale(identifier: "ru_RU")
                wd.dateFormat = "EEEE"
                dayLabel.text = wd.string(from: forecastDate).capitalized
            }
        } else {
            dayLabel.text = day.date
        }

        let temps = day.hour.map { $0.tempC }
        if let min = temps.min(), let max = temps.max() {
            minMaxLabel.text = "\(Int(min))°/\(Int(max))°"
        }

        let noon = day.hour.first { $0.time.contains("12:00") } ?? day.hour.first!
        if let url = URL(string: "https:\(noon.condition.icon)") {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data = data, let img = UIImage(data: data) else { return }
                DispatchQueue.main.async { self.iconImageView.image = img }
            }.resume()
        }
    }
}
