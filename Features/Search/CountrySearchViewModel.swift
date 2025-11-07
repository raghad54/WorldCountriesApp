//
//  CountrySearchMainView.swift
//  WorldCountries
//
//  Created by Raghad's Mac on 07/11/2025.
//

import Foundation
import Combine

final class CountrySearchViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published private(set) var searchResult: [Country] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?   
    
    private let networkService: NetworkServiceProtocol
    private var cancellable = Set<AnyCancellable>()
    
    init(networkService:NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
        setupBindings()
    }
    
    private func setupBindings() {
        $searchQuery
            .debounce(for:.milliseconds(400), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.searchCountries(named: query)
            }
            .store(in: &cancellable)
        
    }
    
    private func searchCountries(named name: String) {
        guard !name.isEmpty else {
            isLoading = false
            searchResult  = []
            errorMessage = nil
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        networkService.searchCountries(by: name)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = (error as? NetworkError)?.errorDescription ?? error.localizedDescription
                }
            } receiveValue: { [weak self] countries in
                self?.searchResult = countries
            }.store(in: &cancellable)
    }
}
