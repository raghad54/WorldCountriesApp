//
//  DetailsView.swift
//  WorldCountries
//
//  Created by Raghad's Mac on 07/11/2025.
//

import SwiftUI

struct CountryDetailView: View {
    let country: Country
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [.blue.opacity(0.1), .mint.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                AsyncImage(url: URL(string: country.flagURL)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                        .cornerRadius(12)
                        .shadow(radius: 6)
                } placeholder: {
                    ProgressView()
                }
                
                Text(country.displayName)
                    .font(.largeTitle.bold())
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Capital:")
                        Spacer()
                        Text(country.capitalName)
                            .bold()
                    }
                    
                    HStack {
                        Text("Currency:")
                        Spacer()
                        Text("\(country.currencyName) (\(country.currencySymbol))")
                            .bold()
                    }
                }
                .padding()
                .background(.thinMaterial)
                .cornerRadius(12)
                .shadow(radius: 4)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(country.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
