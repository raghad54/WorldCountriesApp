//
//  AppCoordinator.swift
//  WorldCountries
//
//  Created by Raghad's Mac on 06/11/2025.
//

import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    @StateObject var countryListViewModel = CountryListViewModel()
    
    @ViewBuilder
    func buildRootView() -> some View {
        NavigationStack(path: binding(\.path)) {
            CountryListView()
                .environmentObject(self)
                .environmentObject(countryListViewModel)
                .navigationDestination(for: Country.self) { country in
                    CountryDetailView(country: country)
                }
        }
    }

    func navigate(to destination: Destination) {
        switch destination {
        case .countryDetail(let country):
            path.append(country)
        }
    }

    enum Destination: Hashable {
        case countryDetail(Country)
    }

    private func binding<Value>(_ keyPath: ReferenceWritableKeyPath<AppCoordinator, Value>) -> Binding<Value> {
        Binding(
            get: { self[keyPath: keyPath] },
            set: { self[keyPath: keyPath] = $0 }
        )
    }
}
