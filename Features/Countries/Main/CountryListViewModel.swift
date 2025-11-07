//
//  MainViewModel.swift
//  WorldCountries
//
//  Created by Raghad's Mac on 06/11/2025.
//

import Foundation
import Combine
import CoreLocation

final class CountryListViewModel: ObservableObject {
    @Published private(set) var countries: [Country] = []
    @Published private(set) var selectedCountries: [Country] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    
    private let networkService: NetworkServiceProtocol
    private let storage: StorageManager
    private let locationManager: LocationManager
    private let resolver: CountryResolver
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        networkService: NetworkServiceProtocol = NetworkService(),
        storage: StorageManager = .shared,
        locationManager: LocationManager = LocationManager(),
        resolver: CountryResolver = CountryResolver()
    ) {
        self.networkService = networkService
        self.storage = storage
        self.locationManager = locationManager
        self.resolver = resolver
        
        self.selectedCountries = storage.loadCountries()
        setupBindings()
    }
    
    private func setupBindings() {
        locationManager.$userLocation
            .compactMap { $0 }
            .first() // only handle the first location update
            .sink { [weak self] location in
                guard let self else { return }
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    await self.detectAndAddCountry(from: location)
                }
            }
            .store(in: &cancellables)
    }
    
    func requestUserLocation() {
        locationManager.requestLocation()
    }
    
    func addCountry(_ country: Country) {
        guard !selectedCountries.contains(country) else { return }
        if selectedCountries.count >= 5 {
            selectedCountries.removeFirst()
        }
        selectedCountries.insert(country, at: 0)
        storage.saveCountries(selectedCountries)
    }
    
    func removeCountry(_ country: Country) {
        selectedCountries.removeAll { $0 == country }
        storage.saveCountries(selectedCountries)
    }
    
    func isSelected(_ country: Country) -> Bool {
        selectedCountries.contains(country)
    }
    
    // MARK: - Private Helpers
    @MainActor
    private func detectAndAddCountry(from location: CLLocation) async {
        isLoading = true
        defer { isLoading = false }
        
        if let country = await resolver.resolveCountry(from: location) {
            addCountry(country)
        } else {
            addDefaultCountry() // no await needed (Combine version)
        }
    }
    
    private func addDefaultCountry() {
        networkService.searchCountries(by: "Egypt")
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Failed to load default country:", error)
                }
            } receiveValue: { [weak self] countries in
                guard let defaultCountry = countries.first else { return }
                self?.addCountry(defaultCountry)
            }
            .store(in: &cancellables)
    }
}
