//
//  AppCoordinator.swift
//  WorldCountries
//
//  Created by Raghad's Mac on 06/11/2025.
//

import Foundation
import SwiftUI

final class AppCoordinator: ObservableObject {
    @Published var selectedCountry: Country? = nil
    @StateObject var countryListViewModel = CountryListViewModel()

    @ViewBuilder
    func buildRootView() -> some View {
        NavigationStack {
            CountryListView()
                .environmentObject(self)
                .environmentObject(countryListViewModel) 
        }
    }

    func showDetails(for country: Country) {
        selectedCountry = country
    }
}
