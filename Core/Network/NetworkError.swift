//
//  NetworkError.swift
//  WorldCountries
//
//  Created by Raghad's Mac on 06/11/2025.
//

import Foundation

enum NetworkError: LocalizedError {
    case badURL
    case invalidResponse
    case decodingError
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .badURL:
            return "Invalid URL."
        case .invalidResponse:
            return "Unexpected response from the server."
        case .decodingError:
            return "Failed to decode data."
        case .serverError(let message):
            return message
        }
    }
}
