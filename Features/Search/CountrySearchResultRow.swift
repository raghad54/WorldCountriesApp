//
//  CountrySearchResultRow.swift
//  WorldCountries
//
//  Created by Raghad's Mac on 07/11/2025.
//

import SwiftUI

struct CountrySearchResultRow: View {
    let country: Country
    let addAction: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: country.flagURL)) { image in
                image.resizable()
                     .scaledToFit()
                     .frame(width: 50, height: 34)
                     .cornerRadius(6)
                     .shadow(radius: 2)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 50, height: 34)
                    .cornerRadius(6)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(country.displayName)
                    .font(.headline)
                Text("Capital: \(country.capitalName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Currency: \(country.currencyName) \(country.currencySymbol)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: addAction) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.blue.gradient)
                    .shadow(radius: 3)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
        .transition(.opacity.combined(with: .scale))
    }
}
