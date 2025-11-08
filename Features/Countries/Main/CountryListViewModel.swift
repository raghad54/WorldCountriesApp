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
    private let storage: StorageProtocol
    private let resolver: CountryResolver

    private var cancellables = Set<AnyCancellable>()
    private let defaultCountryName = "Egypt"
    private let maxSelectedCountries = 5

    init(
        countryService: CountryServiceProtocol = CountryService(),
        locationService: LocationServiceProtocol = LocationService(),
        storage: StorageProtocol = StorageManager.shared,
        resolver: CountryResolver = CountryResolver()
    ) {
        self.countryService = countryService
        self.locationService = locationService
        self.storage = storage
        self.resolver = resolver
        self.selectedCountries = storage.loadCountries()

        bindLocation()
    }

    private func bindLocation() {
        // Track if default country was added this launch to prevent duplicates
        var defaultCountryAddedThisLaunch = false

        locationService.authorizationStatus
            .sink { [weak self] status in
                guard let self else { return }

                switch status {
                case .denied, .restricted:
                    // Add Egypt if list empty and not already added
                    if !defaultCountryAddedThisLaunch &&
                        !self.selectedCountries.contains(where: { $0.displayName == self.defaultCountryName }) {

                        defaultCountryAddedThisLaunch = true
                        Task { await self.addDefaultCountryIfNeeded() }
                    }

                case .authorizedAlways, .authorizedWhenInUse:
                    // Detect location only if list is empty
                    if self.selectedCountries.isEmpty {
                        self.locationService.requestPermission()
                    }

                default: break
                }
            }
            .store(in: &cancellables)

        locationService.userLocation
            .compactMap { $0 }
            .first()
            .sink { [weak self] location in
                guard let self else { return }

                // Only detect country if no countries selected
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
        guard !selectedCountries.contains(country) else { return }

        var temp = selectedCountries
        if let egyptIndex = temp.firstIndex(where: { $0.displayName == defaultCountryName }) {
            // Keep Egypt at top if present
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
        // Only add Egypt if it's not already in the list
        guard !selectedCountries.contains(where: { $0.displayName == defaultCountryName }) else { return }

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
