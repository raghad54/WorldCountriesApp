//
//  Network.swift
//  WorldCountries
//
//  Created by Raghad's Mac on 06/11/2025.
//

import Foundation
import Combine

protocol NetworkServiceProtocol {
    func fetchCountries() -> AnyPublisher<[Country], Error>
}

final class NetworkService: NetworkServiceProtocol {
    private let stringURL = ""
    func fetchCountries() -> AnyPublisher<[Country], Error> {
        guard let url = URL(string: "https://restcountries.com/v3.1/all?fields=name,capital,currencies,flags,latlng") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()}
        
        print("🌍 Fetching countries from:", url)

        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                if let httpResponse = response as? HTTPURLResponse {
                    print("Status code:", httpResponse.statusCode)
                }
                print("Raw data length:", data.count)
                return data
            }
            .decode(type: [Country].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { countries in
                print("Received \(countries.count) countries")
            }, receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("❌ Network error:", error.localizedDescription)
                case .finished:
                    print("✅ Successfully finished fetching.")
                }
            })
            .eraseToAnyPublisher()
    }
}
