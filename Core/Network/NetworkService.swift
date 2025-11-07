//
//  Network.swift
//  WorldCountries
//
//  Created by Raghad's Mac on 06/11/2025.
//

import Foundation
import Combine

protocol NetworkServiceProtocol {
    func searchCountries(by name: String) -> AnyPublisher<[Country], Error>
}

final class NetworkService: NetworkServiceProtocol {
    
    func searchCountries(by name: String) -> AnyPublisher<[Country], Error> {
        guard let url = URL(string: "https://restcountries.com/v3.1/name/\(name)?fields=name,capital,currencies,flags,latlng") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher() }
        
        print("Searching Countries with name \(name)")
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse  }
                    
                    switch httpResponse.statusCode {
                    case  200..<300:
                        return data
                    case 404:
                        throw NetworkError.serverError("No country found matching “\(name)")
                    default:
                        throw NetworkError.serverError("Server return status code “\(httpResponse.statusCode)")
                }
            }
            .decode(type: [Country].self, decoder:JSONDecoder())
            .mapError { error -> NetworkError in
                if let networkError = error as? NetworkError{
                    return networkError
                } else if error is DecodingError {
                    return .decodingError
                } else {
                    return .serverError(error.localizedDescription)
                }   
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
