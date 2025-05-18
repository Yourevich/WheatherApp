//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Илья Зорин on 14.05.2025.
//


import Foundation
import CoreLocation

// Сервис для работы с API погоды
enum WeatherServiceError: Error {
    case invalidURL
    case requestFailed
    case serverError(Int)
    case decodingFailed
    case noInternet
}

final class WeatherService: WeatherServiceProtocol {

    private let apiKey = "fa8b3df74d4042b9aa7135114252304"
    private let baseURL = "https://api.weatherapi.com/v1"
    
//Запрашиваем текущую погоду для заданных координат
    func fetchCurrentWeather(for location: CLLocationCoordinate2D) async throws -> CurrentWeatherResponse {
        let urlString = "\(baseURL)/current.json?key=\(apiKey)&q=\(location.latitude),\(location.longitude)&lang=ru"
        guard let url = URL(string: urlString) else {
            throw WeatherServiceError.invalidURL
        }

        // Выполняем сетевой запрос
        let (data, response) = try await URLSession.shared.data(from: url)

        // Проверяем HTTP-статус
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherServiceError.requestFailed
        }
        guard 200..<300 ~= httpResponse.statusCode else {
            throw WeatherServiceError.serverError(httpResponse.statusCode)
        }

        // Декодим
        let decoder = JSONDecoder()
        do {
            let weather = try decoder.decode(CurrentWeatherResponse.self, from: data)
            return weather
        } catch {
            throw WeatherServiceError.decodingFailed
        }
    }
   
    
}

extension WeatherService {
    //Запрашиваем прогноз погоды на 7 дней для заданных координат
    
    func fetchForecast(for location: CLLocationCoordinate2D) async throws -> ForecastResponse {
        let urlString = "\(baseURL)/forecast.json?key=\(apiKey)&q=\(location.latitude),\(location.longitude)&days=7&lang=ru"
        guard let url = URL(string: urlString) else {
            throw WeatherServiceError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse else {
            throw WeatherServiceError.requestFailed
        }
        guard 200..<300 ~= http.statusCode else {
            throw WeatherServiceError.serverError(http.statusCode)
        }

        let decoder = JSONDecoder()
        do {
            let forecast = try decoder.decode(ForecastResponse.self, from: data)
            return forecast
        } catch {
            throw WeatherServiceError.decodingFailed
        }
    }
}

