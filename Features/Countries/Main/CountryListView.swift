//
//  MainView.swift
//  WorldCountries
//
//  Created by Raghad's Mac on 06/11/2025.
//

import SwiftUI

struct CountryListView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var viewModel: CountryListViewModel
    @State private var showingSearch = false
    @State private var countryToRemove: Country?       // Track the country to remove
    @State private var showRemoveAlert = false
    @Namespace private var animation
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                LinearGradient(
                    colors: [.blue.opacity(0.1), .mint.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 12) {
                    // Header
                    VStack(spacing: 4) {
                        HStack {
                            Image(systemName: "globe.europe.africa.fill")
                                .font(.system(size: 34))
                                .foregroundColor(.blue)
                                .matchedGeometryEffect(id: "icon", in: animation)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Countries")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.blue, .teal],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                Text("Explore capitals and currencies 🌍")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 16)
                    
                    Divider()
                        .padding(.horizontal)
                        .opacity(0.3)
                    
                    // Empty state
                    if viewModel.selectedCountries.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "magnifyingglass.circle")
                                .font(.system(size: 48))
                                .foregroundColor(.blue.opacity(0.7))
                            Text("No countries added yet")
                                .font(.headline)
                            Text("Tap the + button to start exploring 🌏")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .transition(.opacity)
                        Spacer()
                    } else {
                        // Selected countries list
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.selectedCountries) { country in
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(country.displayName)
                                                .font(.title3.bold())
                                            Spacer()
                                            
                                            Button(action: {
                                                countryToRemove = country
                                                showRemoveAlert = true
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                                    .font(.title2)
                                            }
                                        }
                                        Text("Capital: \(country.capitalName)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text("Currency: \(country.currencyName) \(country.currencySymbol)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(16)
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                        }
                        .transition(.opacity)
                    }
                }
                
                Button(action: { showingSearch = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 56))
                        .foregroundColor(.blue)
                }
//.disabled(viewModel.selectedCountries.count >= 5)
                .accessibilityLabel("Add new country")
                .sheet(isPresented: $showingSearch) {
                    CountrySearchView()
                        .environmentObject(viewModel)
                }
            }
            // MARK: - Remove confirmation alert
            .alert("Remove Country?", isPresented: $showRemoveAlert, presenting: countryToRemove) { country in
                Button("Remove", role: .destructive) {
                    withAnimation {
                        viewModel.removeCountry(country)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: { country in
                Text("Are you sure you want to remove \(country.displayName) from your list?")
            }
        }
    }
}
