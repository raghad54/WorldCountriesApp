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
    
    @ViewBuilder
        func buildRootView() -> some View {
            NavigationStack {
                CountryListView()
                    .environmentObject(self)
//                    .navigationDestination(item: $selectedCountry) { country in
//                        //CountryDetailView(country: country)
//                    }
            }
        }

        func showDetails(for country: Country) {
            selectedCountry = country
        }
}


