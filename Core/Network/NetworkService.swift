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
    
    func fetchCountries() -> AnyPublisher<[Country], Error> {
        guard let url = URL(string:"https://restcountries.com/v2/all") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()}
         
        return URLSession.shared.dataTaskPublisher(for:url)
            .map(\.data)
            .decode(type:[Country].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        }
}
