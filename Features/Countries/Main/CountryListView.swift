//
//  MainView.swift
//  WorldCountries
//
//  Created by Raghad's Mac on 06/11/2025.
//

import SwiftUI

struct CountryListView: View {
    @StateObject var viewModel = CountryLisViewModel()
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        NavigationView {
            ZStack {
                // MARK: - Main Content
                List(viewModel.countries) { country in
                    CountryRowView(country: country)
                        .onTapGesture {
                            //coordinator.showCountryDetails(country)
                        }
                        .navigationTitle("Countries")
                }
                .navigationTitle("Countries")
                
                // MARK: - Loading Indicator (Centered)
                if viewModel.isLoading {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        ProgressView("Loading...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .font(.headline)
                            .padding(20)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(radius: 8)
                    }
                    .transition(.opacity)
                }

                // MARK: - Error Overlay
                if let error = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)

                        Text("Something went wrong")
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button("Try Again") {
                            viewModel.fetchCountries()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .controlSize(.large)
                        .padding(.top, 8)
                    }
                    .padding(30)
                    .background(.thinMaterial)
                    .cornerRadius(16)
                    .shadow(radius: 10)
                    .padding()
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut, value: viewModel.isLoading)
            .animation(.easeInOut, value: viewModel.errorMessage)
            .onAppear {
                viewModel.fetchCountries()
            }
        }
    }
}
