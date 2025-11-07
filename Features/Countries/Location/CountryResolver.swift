//
//  CountryResolver.swift
//  WorldCountries
//
//  Created by Raghad's Mac on 07/11/2025.
//

import Foundation
import CoreLocation
import Combine

final class CountryResolver {
    private let geocoder = CLGeocoder()
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    func resolveCountry(from location: CLLocation) async -> Country? {
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            guard let countryName = placemarks.first?.country else { return nil }
            
            let countries = try await networkService
                .searchCountries(by: countryName)
                .asyncValue()
            
            return countries.first
        } catch {
            print("Country resolution failed:", error.localizedDescription)
            return nil
        }
    }
}


extension Publisher {
    func asyncValue() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = first()
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { value in
                        continuation.resume(returning: value)
                        cancellable?.cancel()
                    })
        }
    }
}

