//
//  CountryListViewModelAddRemoveTests.swift
//  WorldCountriesTests
//
//  Created by Raghad's Mac on 08/11/2025.
//

import XCTest
import Combine
@testable import WorldCountries

// MARK: - Protocol for storage so we can mock it
protocol StorageProtocol {
    func saveCountries(_ countries: [Country])
    func loadCountries() -> [Country]
}

// Make real StorageManager conform to StorageProtocol
extension StorageManager: StorageProtocol { }


// MARK: - CountryListViewModel Tests
@MainActor
final class CountryListViewModelTests: XCTestCase {
    var viewModel: CountryListViewModel!
    var mockService: MockNetworkService!
    var mockStorage: MockStorageManager!

    override func setUp() {
        super.setUp()
        mockService = MockNetworkService()
        mockStorage = MockStorageManager()
        viewModel = CountryListViewModel(
            countryService: mockService,
            storage: mockStorage
        )
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        mockStorage = nil
        super.tearDown()
    }

    func testAddCountry() {
        let country = Country(
            name: Name(common: "Japan"),
            capital: ["Tokyo"],
            currencies: ["JPY": Currency(name: "Yen", symbol: "¥")],
            flags: Flag(png: "https://example.com/japan.png"),
            latlng: [35.0, 139.0],
            cca2: "JP"
        )

        viewModel.addCountry(country)

        XCTAssertTrue(viewModel.selectedCountries.contains(country))
        XCTAssertEqual(mockStorage.savedCountries.first?.name.common, "Japan")
    }

    func testRemoveCountry() {
        let country = Country(
            name: Name(common: "France"),
            capital: ["Paris"],
            currencies: ["EUR": Currency(name: "Euro", symbol: "€")],
            flags: Flag(png: "https://example.com/france.png"),
            latlng: [48.8, 2.3],
            cca2: "FR"
        )

        viewModel.addCountry(country)
        viewModel.removeCountry(country)

        XCTAssertFalse(viewModel.selectedCountries.contains(country))
        XCTAssertTrue(mockStorage.savedCountries.isEmpty)
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
        
        mockService.countriesToReturn = [testCountry]
        
        let countries = try! await mockService.searchCountry(by: "Searchland").async()
        
        XCTAssertEqual(countries.count, 1)
        XCTAssertEqual(countries.first?.displayName, "Searchland")
    }
}

// MARK: - Async helper for Combine
extension Publisher where Failure == Error {
    func async() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = self.sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
                cancellable?.cancel()
            } receiveValue: { value in
                continuation.resume(returning: value)
                cancellable?.cancel()
            }
        }
    }
}
