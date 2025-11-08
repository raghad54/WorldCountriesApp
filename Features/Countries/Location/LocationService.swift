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
    }

    var userLocation: AnyPublisher<CLLocation?, Never> {
        $location.eraseToAnyPublisher()
    }

    var authorizationStatus: AnyPublisher<CLAuthorizationStatus, Never> {
        $status.eraseToAnyPublisher()
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let latest = locations.last {
            location = latest
            manager.stopUpdatingLocation()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        status = manager.authorizationStatus
    }
}
