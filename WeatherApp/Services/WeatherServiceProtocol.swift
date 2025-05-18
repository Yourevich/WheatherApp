//
//  WeatherServiceProtocol.swift
//  WeatherApp
//
//  Created by Илья Зорин on 14.05.2025.
//

import Foundation
import UIKit
import CoreLocation

protocol WeatherServiceProtocol {
    func fetchCurrentWeather(for location: CLLocationCoordinate2D) async throws -> CurrentWeatherResponse
    func fetchForecast(for location: CLLocationCoordinate2D) async throws -> ForecastResponse
}
