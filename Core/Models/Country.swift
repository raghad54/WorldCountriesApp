//
//  Countr.swift
//  WorldCountries
//
//  Created by Raghad's Mac on 06/11/2025.
//

import Foundation
import CoreLocation

struct Country: Codable, Identifiable, Equatable {
    let id =  UUID()
    let name: String
    let capital: String
    let region: String?
    let flagURL: String?
    let latlng: [Double]?
    let currencies: [Currency]?
    
    var coordinate: CLLocationCoordinate2D? {
            guard let lat = latlng?.first, let lng = latlng?.last else { return nil }
            return CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
}
