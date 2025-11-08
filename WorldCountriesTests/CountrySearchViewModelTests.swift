//
//  CountrySearchViewModelTests.swift
//  WorldCountriesTests
//
//  Created by Raghad's Mac on 08/11/2025.
//


@testable import WorldCountries
import XCTest
import Combine
import CoreLocation

@MainActor
final class CountryListViewModelSearchTests: XCTestCase {

    var viewModel: CountryListViewModel!
    var mockNetwork: MockNetworkService!
    var mockStorage: MockStorageManager!

    override func setUp() {
        super.setUp()
        mockNetwork = MockNetworkService()
        mockStorage = MockStorageManager()
        viewModel = CountryListViewModel(
            countryService: mockNetwork,
            storage: mockStorage
        )
    }

    override func tearDown() {
        viewModel = nil
        mockNetwork = nil
        mockStorage = nil
        super.tearDown()
    }

    func testSearchCountry() async {
        let testCountry = Country(
            name: Name(common: "Searchland"),
            capital: ["CapitalCity"],
            currencies: ["SRL": Currency(name: "Search Dollar", symbol: "$")],
            flags: Flag(png: ""),
            latlng: [0,0],
            cca2: "SL"
        )
        
        mockNetwork.countriesToReturn = [testCountry]
        
        let countries = try! await mockNetwork.searchCountry(by: "Searchland").async()
        
        XCTAssertEqual(countries.count, 1)
        XCTAssertEqual(countries.first?.displayName, "Searchland")
    }
}


