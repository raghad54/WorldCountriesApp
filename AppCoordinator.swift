//
//  AppCoordinator.swift
//  WorldCountries
//
//  Created by Raghad's Mac on 06/11/2025.
//

import SwiftUI
import CoreLocation

@MainActor
final class AppCoordinator: NSObject, ObservableObject, CLLocationManagerDelegate {
    // MARK: - Published Properties
    @Published var path = NavigationPath()
    @Published var currentLocation: CLLocationCoordinate2D? // Optional current location
    @StateObject var countryListViewModel = CountryListViewModel()
    
    // MARK: - Private Properties
    private let locationManager = CLLocationManager()
    private let defaultCountryCode = "EG" // Fallback if GPS unavailable
    
    // MARK: - Init
    override init() {
        super.init()
        setupLocation()
    }
    
    // MARK: - Location Setup
    private func setupLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        } else {
            addDefaultCountry()
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            addDefaultCountry()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            addDefaultCountry()
            return
        }
        
        currentLocation = location.coordinate
        selectCountryFromLocation(location)
        manager.stopUpdatingLocation() // Only need first location
    }
    
    // MARK: - Helper Methods
    private func selectCountryFromLocation(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if let countryCode = placemarks?.first?.isoCountryCode,
               let country = self.countryListViewModel.countries.first(where: { $0.cca2 == countryCode }) {
                self.countryListViewModel.addCountry(country)
                print("Added country based on GPS: \(country.displayName)")
            } else {
                self.addDefaultCountry()
            }
        }
    }
    
    private func addDefaultCountry() {
        guard let defaultCountry = countryListViewModel.countries.first(where: { $0.cca2 == defaultCountryCode }) else { return }
        countryListViewModel.addCountry(defaultCountry)
        print("Added default country: \(defaultCountry.displayName)")
    }
    
    // MARK: - Navigation
    @ViewBuilder
    func buildRootView() -> some View {
        NavigationStack(path: binding(\.path)) {
            CountryListView()
                .environmentObject(self)
                .environmentObject(countryListViewModel)
                .navigationDestination(for: Country.self) { country in
                    CountryDetailView(country: country)
                }
        }
    }
    
    func navigate(to destination: Destination) {
        switch destination {
        case .countryDetail(let country):
            path.append(country)
        }
    }
    
    enum Destination: Hashable {
        case countryDetail(Country)
    }
    
    private func binding<Value>(_ keyPath: ReferenceWritableKeyPath<AppCoordinator, Value>) -> Binding<Value> {
        Binding(
            get: { self[keyPath: keyPath] },
            set: { self[keyPath: keyPath] = $0 }
        )
    }
}

