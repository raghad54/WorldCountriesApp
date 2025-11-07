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
    @State private var countryToRemove: Country?
    @State private var showRemoveAlert = false
    @Namespace private var animation
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            LinearGradient(
                colors: [.blue.opacity(0.1), .mint.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 12) {
                header
                
                Divider()
                    .padding(.horizontal)
                    .opacity(0.3)
                
                if viewModel.selectedCountries.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.selectedCountries) { country in
                                CountryRowView(
                                    country: country,
                                    onRemove: {
                                        countryToRemove = country
                                        showRemoveAlert = true
                                    },
                                    onTap: {
                                        coordinator.navigate(to: .countryDetail(country))
                                    }
                                )
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
            .accessibilityLabel("Add new country")
            .sheet(isPresented: $showingSearch) {
                CountrySearchView()
                    .environmentObject(viewModel)
            }
        }
        // Remove confirmation
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

private extension CountryListView {
    var header: some View {
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
    }
    
}

private extension CountryListView {
    var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "magnifyingglass.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue.opacity(0.8))
                
                Text("No Countries Added")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Tap the + button to start exploring 🌏")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .multilineTextAlignment(.center)
            Spacer()
        }
        .transition(.opacity)
    }
}
