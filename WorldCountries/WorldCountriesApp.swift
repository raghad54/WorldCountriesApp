//
//  WorldCountriesApp.swift
//  WorldCountries
//
//  Created by Raghad's Mac on 06/11/2025.
//

import SwiftUI

@main
struct WorldCountriesApp: App {
    @StateObject private var coordinator =  AppCoordinator()
    @StateObject private var countryListViewModel = CountryListViewModel()
    
    var body: some Scene {
        WindowGroup {
            coordinator.buildRootView()
                .environmentObject(countryListViewModel)
                .environmentObject(coordinator)
        }
    }
}
