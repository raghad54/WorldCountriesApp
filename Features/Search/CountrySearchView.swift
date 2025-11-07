//
//  CountrySearchView.swift
//  WorldCountries
//
//  Created by Raghad's Mac on 07/11/2025.
//

import SwiftUI

struct CountrySearchView: View {
    @StateObject private var viewModel = CountrySearchViewModel()
    @EnvironmentObject var listViewModel: CountryListViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.mint.opacity(0.2), .blue.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search for a country...", text: $viewModel.searchQuery)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                        if !viewModel.searchQuery.isEmpty {
                            Button(action: { viewModel.searchQuery = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray.opacity(0.6))
                            }
                        }
                    }
                    .padding(10)
                    .background(Color(.systemBackground).opacity(0.9))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    if viewModel.isLoading {
                        ProgressView("Searching...")
                            .padding(.top, 24)
                    }
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(viewModel.searchResult) { country in
                                CountrySearchResultRow(
                                    country: country,
                                    addAction: {
                                        withAnimation(.spring()) {
                                            listViewModel.addCountry(country)
                                            dismiss()
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                }
            }
            .navigationTitle("Search Country 🌎")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
