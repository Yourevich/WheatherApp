//
//  CurrentWeather.swift
//  WeatherApp
//
//  Created by Илья Зорин on 14.05.2025.
//

import Foundation

struct CurrentWeatherResponse: Codable, Hashable {
    let location: Location
    let current: Current
}

struct Location: Codable, Hashable {
    let name: String
    let country: String
    let localtime: String
}

struct Current: Codable, Hashable {
    let lastUpdated: String
    let tempC: Double
    let feelslikeC: Double
    let isDay: Int
    let condition: WeatherCondition

    enum CodingKeys: String, CodingKey {
        case lastUpdated = "last_updated"
        case tempC = "temp_c"
        case feelslikeC = "feelslike_c"
        case isDay = "is_day"
        case condition
    }
}

struct WeatherCondition: Codable, Hashable {
    let text: String
    let icon: String
}
