//
//  StorageManager.swift
//  WorldCountries
//
//  Created by Raghad's Mac on 06/11/2025.
//

import Foundation

protocol StorageProtocol {
    func saveCountries(_ countries: [Country])
    func loadCountries() -> [Country]
    func saveDefaultCountryAddedFlag(_ added: Bool)
    func loadDefaultCountryAddedFlag() -> Bool
    func markUserRespondedToLocationPermission()
    func didUserRespondToLocationPermission() -> Bool
}

// MARK: - StorageManager
final class StorageManager: StorageProtocol {
    
    static let shared = StorageManager()
    private let countriesKey = "selected_countries"
    private let defaultAddedKey = "default_country_added"
    private let userRespondedKey = "user_responded_permission"
    
    func saveCountries(_ countries: [Country]) {
        if let data = try? JSONEncoder().encode(countries) {
            UserDefaults.standard.set(data, forKey: countriesKey)
        }
    }
    
    func loadCountries() -> [Country] {
        guard let data = UserDefaults.standard.data(forKey: countriesKey),
              let countries = try? JSONDecoder().decode([Country].self, from: data) else { return [] }
        return countries
    }
    
    func saveDefaultCountryAddedFlag(_ added: Bool) {
        UserDefaults.standard.set(added, forKey: defaultAddedKey)
    }
    
    func loadDefaultCountryAddedFlag() -> Bool {
        UserDefaults.standard.bool(forKey: defaultAddedKey)
    }
    
    func markUserRespondedToLocationPermission() {
        UserDefaults.standard.set(true, forKey: userRespondedKey)
    }
    
    func didUserRespondToLocationPermission() -> Bool {
        UserDefaults.standard.bool(forKey: userRespondedKey)
    }
}
