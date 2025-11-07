//
//  MainViewModel.swift
//  WorldCountries
//
//  Created by Raghad's Mac on 06/11/2025.
//

import Foundation
import Combine


final class CountryListViewModel: ObservableObject {
    
    @Published private(set) var countries: [Country] = []
    @Published private(set) var selectedCountries: [Country] =  []
    
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    
    private var cancellable = Set<AnyCancellable>()
    private let networkService :NetworkServiceProtocol
    private let storage: StorageManager
    
    init(networkService:NetworkServiceProtocol = NetworkService(), storage: StorageManager = .shared) {
        self.networkService = networkService
        self.storage = storage
        self.selectedCountries = storage.loadCountries()
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
        selectedCountries.removeAll {$0 == country}
        storage.saveCountries(selectedCountries)
    }
    
    // To check if country is selected!
    func isSelected(_ country: Country) -> Bool {
        selectedCountries.contains(country)
    }
}
