//
//  CountryService.swift
//  WorldCountries
//
//  Created by Raghad's Mac on 08/11/2025.
//

import Foundation
import Combine

protocol CountryServiceProtocol {
    func searchCountry(by name: String) -> AnyPublisher<[Country], Error>
}

final class CountryService: CountryServiceProtocol {
    private let network: NetworkServiceProtocol

    init(network: NetworkServiceProtocol = NetworkService()) {
        self.network = network
    }

    func searchCountry(by name: String) -> AnyPublisher<[Country], Error> {
        network.searchCountries(by: name)
    }
}
