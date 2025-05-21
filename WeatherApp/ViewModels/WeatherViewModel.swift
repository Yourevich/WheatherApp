//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Илья Зорин on 14.05.2025.
//

import Foundation
import CoreLocation
import Network

// ViewModel для работы с погодой и состоянием сети
@MainActor
final class WeatherViewModel: WeatherViewModelProtocol {
    
    // MARK: - Колбэки для обновления UI
    var onWeatherUpdate: ((CurrentWeatherResponse) -> Void)?
    var onHourlyUpdate: (([HourlyForecastEntry]) -> Void)?
    var onDailyUpdate:   (([ForecastDay]) -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    
    // Храним последние полученные координаты
    private var lastCoordinates: CLLocationCoordinate2D?
    
    private let weatherService: WeatherServiceProtocol
    
    // MARK: - Init
    init(weatherService: WeatherServiceProtocol) {
        self.weatherService = weatherService
    }
    
    //Запрашиваем разрешение на геолокацию и ждём координаты
    func start() {
        onLoadingChanged?(true)
        LocationManager.shared.onLocationUpdate = { [weak self] coord in
            guard let self = self else { return }
            self.lastCoordinates = coord  // ← сохраняем
            self.loadWeather(for: coord)
        }
        LocationManager.shared.requestLocation()
    }
    
    func loadWeather(for coordinates: CLLocationCoordinate2D) {
        lastCoordinates = coordinates
        onLoadingChanged?(true)

        Task {
            do {
                // 1) Текущая погода
                let current = try await weatherService.fetchCurrentWeather(for: coordinates)
                onWeatherUpdate?(current)

                // 2) Почасовой прогноз
                let forecast = try await weatherService.fetchForecast(for: coordinates)
                let hours = filterHours(from: forecast, using: current.location.localtime)
                onHourlyUpdate?(hours)

                // 3) Трёхдневный прогноз: Сегодня, Завтра, Послезавтра
                let allDays = forecast.forecast.forecastday
                let threeDays = nextThreeDays(from: allDays)
                onDailyUpdate?(threeDays)

            } catch {
                // Обработка ошибок сети и других случаев
                let message: String
                if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
                    message = "Интернет недоступен. Проверьте соединение и нажмите «Повторить»."
                } else {
                    message = "Ошибка загрузки. Попробуйте снова."
                }
                onError?(message)
            }

            // Скрываем индикатор загрузки
            onLoadingChanged?(false)
        }
    }
    
    
    //Повторный запрос с принятыми геоданными
    func retryLastRequest() {
        guard let coords = lastCoordinates else {
            // Если всё же нет saved coords — то просто ничего не делаем
            return
        }
        loadWeather(for: coords)
    }
    
    private func filterHours(
        from forecast: ForecastResponse,
        using localtime: String
    ) -> [HourlyForecastEntry] {
        // 1. Настраиваем парсер дат
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "ru_RU_POSIX")
        
        guard let currentDate = formatter.date(from: localtime),
              let todayDay = forecast.forecast.forecastday.first else {
            return []
        }
        
        // 2. Преобразуем массив today.hour к [(entry, date)]
        let todayEntries: [(entry: HourlyForecastEntry, date: Date)] = todayDay.hour.compactMap {
            guard let date = formatter.date(from: $0.time) else { return nil }
            return (entry: $0, date: date)
        }
        
        // 3. Находим последний час <= currentDate
        let pastOrEqual = todayEntries.filter { $0.date <= currentDate }
        let firstSlot = pastOrEqual.max(by: { $0.date < $1.date })?.entry
        
        // 4. Берём все часы > currentDate
        let nextSlots = todayEntries
            .filter { $0.date > currentDate }
            .map { $0.entry }
        
        // 5. Собираем итоговый массив
        var result: [HourlyForecastEntry] = []
        if let first = firstSlot {
            result.append(first)       // этот будет помечен как "Сейчас"
        }
        result.append(contentsOf: nextSlots)
        
        // 6. Добавляем весь завтрашний день
        if forecast.forecast.forecastday.count > 1 {
            result.append(contentsOf: forecast.forecast.forecastday[1].hour)
        }
        
        return result
    }
    
    /// Возвращает ровно три прогноза: сегодня, завтра и послезавтра
    private func nextThreeDays(from allDays: [ForecastDay]) -> [ForecastDay] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ru_RU_POSIX")

        // 1) Начало текущего дня
        let today = Calendar.current.startOfDay(for: Date())

        // 2) Преобразуем в массив (ForecastDay, Date)
        let pairs: [(ForecastDay, Date)] = allDays.compactMap { day in
            guard let d = formatter.date(from: day.date) else { return nil }
            return (day, Calendar.current.startOfDay(for: d))
        }

        // 3) Фильтруем всё, что не раньше сегодня, и сортируем
        let filtered = pairs
          .filter { $0.1 >= today }
          .sorted { $0.1 < $1.1 }

        // 4) Берём первые 3 и возвращаем модели
        return filtered.prefix(3).map { $0.0 }
    }
}

