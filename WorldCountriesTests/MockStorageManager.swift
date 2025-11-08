//
//  MockStorageManager.swift
//  WorldCountriesTests
//
//  Created by Raghad's Mac on 08/11/2025.
//

@testable import WorldCountries

final class MockStorageManager: StorageProtocol {
    func saveDefaultCountryAddedFlag(_ added: Bool) {
    }
    
    func loadDefaultCountryAddedFlag() -> Bool {
        return false
    }
    
    func markUserRespondedToLocationPermission() {
    }
    
    func didUserRespondToLocationPermission() -> Bool {
        return false
    }
    
    var savedCountries: [Country] = []

    func saveCountries(_ countries: [Country]) {
        savedCountries = countries
    }

    func loadCountries() -> [Country] {
        savedCountries
    }
}
