//
//  MockStorageManager.swift
//  WorldCountriesTests
//
//  Created by Raghad's Mac on 08/11/2025.
//

@testable import WorldCountries

final class MockStorageManager: StorageProtocol {
    var savedCountries: [Country] = []

    func saveCountries(_ countries: [Country]) {
        savedCountries = countries
    }

    func loadCountries() -> [Country] {
        savedCountries
    }
}
