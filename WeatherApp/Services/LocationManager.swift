//
//  LocationManager.swift
//  WeatherApp
//
//  Created by Илья Зорин on 14.05.2025.
//

import Foundation
import CoreLocation

//Менеджер для работы с геолокацией пользователя. Запрашиваем разрешения и выдаём координаты через замыкание onLocationUpdate

final class LocationManager: NSObject {
    static let shared = LocationManager()
    private let manager = CLLocationManager()
    
    var onLocationUpdate: ((CLLocationCoordinate2D) -> Void)?

    private override init() {
        super.init()
        manager.delegate = self
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    //Вызывается при изменении статуса гео
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            break

        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()

        case .denied, .restricted:
            let moscow = CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173)
            onLocationUpdate?(moscow)
        @unknown default:
            let moscow = CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173)
            onLocationUpdate?(moscow)
        }
    }


    //Вызываем при успешном получении координат
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = locations.first?.coordinate {
            onLocationUpdate?(coord)
        } else {
            let moscow = CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173)
            onLocationUpdate?(moscow)
        }
    }
    //Вызваем при ошибке получения гео
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let moscow = CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173)
        onLocationUpdate?(moscow)
    }
    
    
}





