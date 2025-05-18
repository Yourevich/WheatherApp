//
//  WeatherViewModelProtocol.swift
//  WeatherApp
//
//  Created by Илья Зорин on 18.05.2025.
//

import Foundation
@MainActor

protocol WeatherViewModelProtocol: AnyObject {
    var onWeatherUpdate: ((CurrentWeatherResponse)->Void)? { get set }
    var onHourlyUpdate: (([HourlyForecastEntry])->Void)?  { get set }
    var onDailyUpdate:   (([ForecastDay])->Void)?        { get set }
    var onError:         ((String)->Void)?               { get set }
    var onLoadingChanged:((Bool)->Void)?                 { get set }
    func start()
    func retryLastRequest()
}
