//
//  LocationService.swift
//  WorldCountries
//
//  Created by Raghad's Mac on 07/11/2025.
//
import CoreLocation
import Combine

final class LocationService: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    private let subject = PassthroughSubject<CLLocation, Never>()
    
    var locationPublisher: AnyPublisher<CLLocation, Never> {
        subject.eraseToAnyPublisher()
    }

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestPermissionAndLocation() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            subject.send(location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error:", error.localizedDescription)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            break
        }
    }
}
