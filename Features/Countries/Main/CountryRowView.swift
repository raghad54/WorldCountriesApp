//
//  CountryRowView.swift
//  WorldCountries
//
//  Created by Raghad's Mac on 07/11/2025.
//

import SwiftUI

struct CountryRowView: View {
    let country: Country
    let onRemove: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: country.flagURL)) { image in
                    image
                        .resizable()
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
                
                Text(country.displayName)
                    .font(.title3.bold())
                
                Spacer()
                
                Button(action: onRemove) {
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
        .onTapGesture(perform: onTap)
    }
}

