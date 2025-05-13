//
//  MapViewModelTests.swift
//  PinFlowTests
//
//  Created by Mine Rala on 13.05.2025.
//

import XCTest
import CoreLocation
@testable import PinFlow

final class MapViewModelTests: XCTestCase {
    var sut: MapViewModel!
    var mockLocationManager: MockLocationManager!
    var mockCoreDataManager: MockCoreDataManager!
    var mockDelegate: MockMapViewModelDelegate!

    override func setUp() {
        super.setUp()
        mockLocationManager = MockLocationManager()
        mockCoreDataManager = MockCoreDataManager()
        mockDelegate = MockMapViewModelDelegate()
        sut = MapViewModel(locationManager: mockLocationManager, coreDataManager: mockCoreDataManager)
        sut.delegate = mockDelegate
        mockLocationManager.delegate = sut
    }

    override func tearDown() {
        sut = nil
        mockLocationManager = nil
        mockCoreDataManager = nil
        mockDelegate = nil
        super.tearDown()
    }

    func test_viewDidLoad_shouldAddMarkersAndCheckPermissions() {
        // Given
        mockCoreDataManager.savedLocations = [
            LocationModel.mock(latitude: 38.4550, longitude: 27.1094, context: mockCoreDataManager.context),
            LocationModel.mock(latitude: 38.4587, longitude: 27.0946, context: mockCoreDataManager.context)
        ]
        mockLocationManager.authorizationStatus = .authorizedWhenInUse

        // When
        sut.viewDidLoad()

        // Then
        XCTAssertEqual(mockDelegate.addedMarkers.count, 2)
        XCTAssertEqual(mockDelegate.addedMarkers.first?.1, true)
        XCTAssertEqual(mockDelegate.locationButtonsVisible, true)
        XCTAssertTrue(mockCoreDataManager.fetchAllLocationsCalled)
    }

    func test_toggleTracking_shouldStartTrackingIfNotTracking() {
        // Given
        mockLocationManager.isTracking = false

        // When
        sut.toggleTracking()

        // Then
        XCTAssertTrue(mockLocationManager.startTrackingCalled)
        XCTAssertEqual(mockDelegate.toggleTrackingButtonText, AppString.stop.localized)
    }

    func test_toggleTracking_shouldStopTrackingIfTracking() {
        // Given
        mockLocationManager.isTracking = true

        // When
        sut.toggleTracking()

        // Then
        XCTAssertTrue(mockLocationManager.stopTrackingCalled)
        XCTAssertEqual(mockDelegate.toggleTrackingButtonText, AppString.start.localized)
    }

    func test_resetRoute_shouldClearSavedLocationsAndCallDelete() {
        // When
        sut.resetRoute()

        // Then
        XCTAssertTrue(mockCoreDataManager.deleteAllLocationsCalled)
        XCTAssertTrue(mockCoreDataManager.savedLocations.isEmpty)
    }

    func test_locationManagerDidFail_shouldShowError() {
        // Given
        let nsError = NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock Error"])
        let error = AppError.genericLocationError(nsError)

        // When
        mockLocationManager.simulateLocationFailure(with: error)

        // Then
        XCTAssertEqual(mockDelegate.errorMessage, "Mock Error")
    }

    func test_checkLocationPermission_notDetermined_shouldRequestWhenInUse() {
        // Given
        mockLocationManager.authorizationStatus = .notDetermined

        // When
        sut.viewDidLoad()

        // Then
        XCTAssertTrue(mockLocationManager.requestWhenInUseAuthorizationCalled)
        XCTAssertEqual(mockDelegate.locationButtonsVisible, false)
    }

    func test_checkLocationPermission_authorizedAlways_shouldShowButtons() {
        // Given
        mockLocationManager.authorizationStatus = .authorizedAlways

        // When
        sut.viewDidLoad()

        // Then
        XCTAssertEqual(mockDelegate.locationButtonsVisible, true)
    }

    func test_checkLocationPermission_denied_shouldShowAlert() {
        // Given
        mockLocationManager.authorizationStatus = .denied

        // When
        sut.viewDidLoad()

        // Then
        XCTAssertEqual(mockDelegate.locationButtonsVisible, false)
        XCTAssertTrue(mockDelegate.locationPermissionAlertShown)
    }
}
