//
//  MockCoreDataManagerTests.swift
//  PinFlowTests
//
//  Created by Mine Rala on 13.05.2025.
//

import XCTest
import Combine
@testable import PinFlow

final class MockCoreDataManagerTests: XCTestCase {

    var mockCoreDataManager: MockCoreDataManager!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockCoreDataManager = MockCoreDataManager()
        cancellables = []
    }

    override func tearDown() {
        mockCoreDataManager = nil
        cancellables.removeAll()
        super.tearDown()
    }

    func testSaveLocation() {
        // Given
        let latitude: Double = 38.4192
        let longitude: Double = 27.1287

        // When
        mockCoreDataManager.saveLocation(latitude: latitude, longitude: longitude)

        // Then
        XCTAssertEqual(mockCoreDataManager.savedLocations.count, 1)
        XCTAssertEqual(mockCoreDataManager.savedLocations.first?.latitude, latitude)
        XCTAssertEqual(mockCoreDataManager.savedLocations.first?.longitude, longitude)
        XCTAssertTrue(mockCoreDataManager.saveContextCalled)
        XCTAssertTrue(mockCoreDataManager.saveLocationCalled)
    }

    func testFetchAllLocations() {
        // Given
        let latitude1: Double = 38.4192
        let longitude1: Double = 27.1287
        mockCoreDataManager.saveLocation(latitude: latitude1, longitude: longitude1)

        let latitude2: Double = 41.0082
        let longitude2: Double = 28.9784
        mockCoreDataManager.saveLocation(latitude: latitude2, longitude: longitude2)

        // When
        let locations = mockCoreDataManager.fetchAllLocations()

        // Then
        XCTAssertEqual(locations.count, 2)
        XCTAssertFalse(locations.isEmpty)
        XCTAssertEqual(locations[0].latitude, latitude1)
        XCTAssertEqual(locations[1].latitude, latitude2)
        XCTAssertTrue(mockCoreDataManager.fetchAllLocationsCalled)
    }

    func testDeleteAllLocations() {
        // Given
        mockCoreDataManager.saveLocation(latitude: 38.4192, longitude: 27.1287)
        mockCoreDataManager.saveLocation(latitude: 41.0082, longitude: 28.9784)

        // When
        mockCoreDataManager.deleteAllLocations()

        // Then
        XCTAssertEqual(mockCoreDataManager.savedLocations.count, 0)
        XCTAssertTrue(mockCoreDataManager.deleteAllLocationsCalled)
    }

    func testSaveLocationTriggersSaveContext() {
        // When
        mockCoreDataManager.saveLocation(latitude: 38.4192, longitude: 27.1287)

        // Then
        XCTAssertTrue(mockCoreDataManager.saveContextCalled)
    }

    func testDeleteAllLocationsErrorHandling() {
        // Given
        var errorHandled = false

        mockCoreDataManager.errorPublisher
            .sink { _ in
                errorHandled = true
            }
            .store(in: &cancellables)

        // When
        mockCoreDataManager.deleteAllLocations()

        // Then
        XCTAssertTrue(errorHandled, "Error publisher should be triggered during deleteAllLocations.")
    }
}
