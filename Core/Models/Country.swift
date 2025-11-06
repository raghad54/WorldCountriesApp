//
//  Countr.swift
//  WorldCountries
//
//  Created by Raghad's Mac on 06/11/2025.
//

import Foundation
import CoreLocation

struct Country: Identifiable, Codable, Equatable {
    var id = UUID()
    let name: Name
    let capital: [String]?
    let currencies: [String: Currency]?
    let flags: Flags
    let latlng: [Double]?
    
    var displayName: String {
        name.common
    }
    
    var capitalName: String {
        capital?.first ?? "No Capital"
    }
    
    var currencyName: String {
        currencies?.values.first?.name ?? "Unknown"
    }
    
    var currencySymbol: String {
        currencies?.values.first?.symbol ?? ""
    }
    
    var flagURL: String {
        flags.png
    }
    
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latlng?.first, let lng = latlng?.last else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}

struct Name: Codable, Equatable {
    let common: String
}

struct Flags: Codable, Equatable {
    let png: String
}
