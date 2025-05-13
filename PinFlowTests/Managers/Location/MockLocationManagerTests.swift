//
//  MockLocationManagerTests.swift
//  PinFlowTests
//
//  Created by Mine Rala on 13.05.2025.
//

import XCTest
import CoreLocation
@testable import PinFlow

final class MockLocationManagerTests: XCTestCase {
    var mockLocationManager: MockLocationManager!
    var mockDelegate: MockLocationManagerDelegate!

    override func setUp() {
        super.setUp()
        mockLocationManager = MockLocationManager()
        mockDelegate = MockLocationManagerDelegate()
        mockLocationManager.delegate = mockDelegate
    }

    override func tearDown() {
        mockLocationManager = nil
        mockDelegate = nil
        super.tearDown()
    }

    func testRequestWhenInUseAuthorization() {
        // When
        mockLocationManager.requestWhenInUseAuthorization()

        // Then
        XCTAssertTrue(mockLocationManager.requestWhenInUseAuthorizationCalled)
    }

    func testRequestAlwaysAuthorization() {
        // When
        mockLocationManager.requestAlwaysAuthorization()

        // Then
        XCTAssertTrue(mockLocationManager.requestAlwaysAuthorizationCalled)
    }

    func testStartTracking() {
        // When
        mockLocationManager.startTracking()

        // Then
        XCTAssertTrue(mockLocationManager.startTrackingCalled)
        XCTAssertTrue(mockLocationManager.isTracking)
    }

    func testStopTracking() {
        // Given
        mockLocationManager.startTracking()

        // When
        mockLocationManager.stopTracking()

        // Then
        XCTAssertTrue(mockLocationManager.stopTrackingCalled)
        XCTAssertFalse(mockLocationManager.isTracking)
    }

    func testCurrentAuthorizationStatus() {
        // Given
        mockLocationManager.authorizationStatus = .authorizedWhenInUse

        // When
        let status = mockLocationManager.currentAuthorizationStatus()

        // Then
        XCTAssertEqual(status, .authorizedWhenInUse)
        XCTAssertTrue(mockLocationManager.currentAuthorizationStatusCalled)
    }

    func testSimulateLocationUpdate() {
        // When
        mockLocationManager.simulateLocationUpdate(latitude: 38.4550, longitude: 27.1094)

        // Then
        XCTAssertTrue(mockDelegate.didUpdateCalled)
        XCTAssertEqual(mockDelegate.lastLocation?.coordinate.latitude, 38.4550)
        XCTAssertEqual(mockDelegate.lastLocation?.coordinate.longitude, 27.1094)
    }

    func testSimulateAuthorizationChange() {
        // When
        mockLocationManager.simulateAuthorizationChange(to: .denied)

        // Then
        XCTAssertTrue(mockDelegate.didChangeAuthorizationCalled)
        XCTAssertEqual(mockDelegate.lastAuthorizationStatus, .denied)
    }

    func testSimulateLocationFailure() {
        // When
        mockLocationManager.simulateLocationFailure(with: .locationNetwork)

        // Then
        XCTAssertTrue(mockDelegate.didFailCalled, "Expected failure to be triggered.")

        if case .locationNetwork = mockDelegate.lastError {
            // Passed
        } else {
            XCTFail("Expected error to be .locationNetwork")
        }
    }
}
