//
//  HourlyForecast.swift
//  WeatherApp
//
//  Created by Илья Зорин on 14.05.2025.
//

import Foundation
import Foundation

struct ForecastResponse: Codable, Hashable {
    let forecast: Forecast
}

struct Forecast: Codable, Hashable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Codable, Hashable {
    let date: String
    let hour: [HourlyForecastEntry]
}


struct HourlyForecastEntry: Codable, Hashable {
    let time: String
    let tempC: Double
    let condition: WeatherCondition      

    enum CodingKeys: String, CodingKey {
        case time
        case tempC = "temp_c"
        case condition
    }
}
