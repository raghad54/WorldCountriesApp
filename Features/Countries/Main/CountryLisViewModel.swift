//
//  MainViewModel.swift
//  WorldCountries
//
//  Created by Raghad's Mac on 06/11/2025.
//

import Foundation
import Combine


final class CountryLisViewModel: ObservableObject {
    
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
    }
    
    func fetchCountries() {
        isLoading = true
        networkService.fetchCountries()
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] countries in
                self?.countries = countries
            }
            .store(in:&cancellable)
    }
    
    func addCountry(_ country: Country) {
        var saved  = storage.loadCountries()
        guard !saved.contains(country), saved.count < 5 else { return }
        saved.append(country)
        storage.saveCountries(saved)
        countries = saved
    }
    
    func removeCountries(_ country: Country) {
        var saved = storage.loadCountries()
        saved.removeAll {$0 == country}
        storage.saveCountries(saved)
        countries = saved
    }
}
