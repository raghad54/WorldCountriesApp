//
//  LocationService.swift
//  WorldCountries
//
//  Created by Raghad's Mac on 07/11/2025.
//

import Foundation
import Combine
import CoreLocation

protocol LocationServiceProtocol {
    var userLocation: AnyPublisher<CLLocation?, Never> { get }
    var authorizationStatus: AnyPublisher<CLAuthorizationStatus, Never> { get }
    func requestPermission()
}

final class LocationService: NSObject, ObservableObject, LocationServiceProtocol {
    private let manager = CLLocationManager()

    @Published private var location: CLLocation?
    @Published private var status: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        status = manager.authorizationStatus
    }

    var userLocation: AnyPublisher<CLLocation?, Never> {
        $location.eraseToAnyPublisher()
    }

    var authorizationStatus: AnyPublisher<CLAuthorizationStatus, Never> {
        $status.eraseToAnyPublisher()
    }

    func requestPermission() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location access denied or restricted")
        @unknown default:
            break
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        status = manager.authorizationStatus

        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .denied, .restricted, .notDetermined:
            break
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let latest = locations.last {
            location = latest
            // Stop updating if you only need one location
            manager.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error:", error.localizedDescription)
    }
}
