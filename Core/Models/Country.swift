//
//  Countr.swift
//  WorldCountries
//
//  Created by Raghad's Mac on 06/11/2025.
//

import Foundation
import CoreLocation

struct Country: Identifiable, Codable, Equatable {
    let id = UUID()
    let name: Name
    let capital: [String]?
    let currencies: [String: Currency]?
    let flags: Flag
    let latlng: [Double]?
    
    var displayName: String {
        name.common
    }
    
    var capitalName: String {
        capital?.first ?? "-"
    }
    
    var currencyName: String {
        currencies?.values.first?.name ?? "-"
    }
    
    var currencySymbol: String {
        currencies?.values.first?.symbol ?? "-"
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

struct Flag: Codable, Equatable {
    let png: String
}
