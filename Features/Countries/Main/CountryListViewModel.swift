//
//  MainViewModel.swift
//  WorldCountries
//
//  Created by Raghad's Mac on 06/11/2025.
//

import Foundation
import Combine
import CoreLocation

@MainActor
final class CountryListViewModel: ObservableObject {
    
    @Published private(set) var selectedCountries: [Country] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    private let countryService: CountryServiceProtocol
    private let locationService: LocationServiceProtocol
    private let storage: StorageManager
    private let resolver: CountryResolver
    
    private var cancellables = Set<AnyCancellable>()
    private let defaultCountryName = "Egypt"
    private let maxSelectedCountries = 5
    
    init(
        countryService: CountryServiceProtocol = CountryService(),
        locationService: LocationServiceProtocol = LocationService(),
        storage: StorageManager = .shared,
        resolver: CountryResolver = CountryResolver()
    ) {
        self.countryService = countryService
        self.locationService = locationService
        self.storage = storage
        self.resolver = resolver
        self.selectedCountries = storage.loadCountries()
        
        bindLocation()
        
        // Ensure default country if list is empty on first launch
        Task { await addDefaultCountryIfNeeded() }
    }
    
    private func bindLocation() {
        locationService.authorizationStatus
            .sink { [weak self] status in
                guard let self else { return }
                if (status == .denied || status == .restricted) && self.selectedCountries.isEmpty {
                    Task { await self.addDefaultCountryIfNeeded() }
                }
            }
            .store(in: &cancellables)
        
        locationService.userLocation
            .compactMap { $0 }
            .first()
            .sink { [weak self] location in
                guard let self else { return }
                if self.selectedCountries.isEmpty {
                    Task { await self.detectAndAddCountry(from: location) }
                }
            }
            .store(in: &cancellables)
    }
    
    func requestUserLocation() {
        locationService.requestPermission()
    }
    
    func addCountry(_ country: Country) {
        // Prevent duplicates
        guard !selectedCountries.contains(country) else { return }
        
        var temp = selectedCountries
        if let egyptIndex = temp.firstIndex(where: { $0.displayName == defaultCountryName }) {
            temp.removeAll { $0 == country }
            if temp.count >= maxSelectedCountries,
               let removableIndex = temp.lastIndex(where: { $0.displayName != defaultCountryName }) {
                temp.remove(at: removableIndex)
            }
            temp.insert(country, at: 0)
        } else {
            temp.append(country)
        }
        
        selectedCountries = temp
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
    private func detectAndAddCountry(from location: CLLocation) async {
        isLoading = true
        defer { isLoading = false }
        
        if let country = await resolver.resolveCountry(from: location) {
            addCountry(country)
        } else {
            await addDefaultCountryIfNeeded()
        }
    }
    
    private func addDefaultCountryIfNeeded() async {
        // Only add if list is completely empty
        guard selectedCountries.isEmpty else { return }
        
        do {
            let countries = try await countryService.searchCountry(by: defaultCountryName).async()
            if let egypt = countries.first {
                selectedCountries.append(egypt)
                storage.saveCountries(selectedCountries)
            }
        } catch {
            errorMessage = "Failed to load default country: \(error.localizedDescription)"
        }
    }
}

// MARK: - Combine Publisher to Async helper
extension Publisher where Failure == Error {
    func async() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = self.sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
                cancellable?.cancel()
            } receiveValue: { value in
                continuation.resume(returning: value)
                cancellable?.cancel()
            }
        }
    }
}
