//
//  CountryRowView.swift
//  WorldCountries
//
//  Created by Raghad's Mac on 06/11/2025.
//

import SwiftUI

struct CountryRowView: View {
    let country: Country
    
    var body: some View {
        HStack{
            Text(country.displayName)
            Spacer()
            //Text(country.flag)
        }
    }
}
