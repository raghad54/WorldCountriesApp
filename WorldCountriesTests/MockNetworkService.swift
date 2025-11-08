//
//  MockNetworkService.swift
//  WorldCountriesTests
//
//  Created by Raghad's Mac on 08/11/2025.
//

import Foundation
import Combine
@testable import WorldCountries

final class MockNetworkService: CountryServiceProtocol {
    var countriesToReturn: [Country] = []
    
    func searchCountry(by name: String) -> AnyPublisher<[Country], Error> {
        Just(countriesToReturn)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
