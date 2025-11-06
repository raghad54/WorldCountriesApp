//
//  StorageManager.swift
//  WorldCountries
//
//  Created by Raghad's Mac on 06/11/2025.
//

import Foundation

final class StorageManager {
    
    static let shared = StorageManager()
    private let key = "selected_countries"
    
    func saveCountries(_ countries: [Country]) {
        if let data = try? JSONEncoder().encode(countries) {
            UserDefaults.standard.set(data, forKey:key)
        }
    }
    
    func loadCountries() -> [Country] {
        guard let data = UserDefaults.standard.data(forKey: key), 
                let countries = try? JSONDecoder().decode([Country].self, from: data) else { return [] }
        return countries
    }
}
