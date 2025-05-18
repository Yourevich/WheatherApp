//
//  DailySectionHeaderView.swift
//  WeatherApp
//
//  Created by Илья Зорин on 14.05.2025.
//

import Foundation

import UIKit

final class DailySectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "DailySectionHeaderView"

    private let label: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.text = "Прогноз на 3 дня"
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}
