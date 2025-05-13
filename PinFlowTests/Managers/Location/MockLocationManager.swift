//
//  MockLocationManager.swift
//  PinFlowTests
//
//  Created by Mine Rala on 13.05.2025.
//

import CoreLocation
@testable import PinFlow

final class MockLocationManager: LocationManagerProtocol {

    // MARK: - Delegate
    weak var delegate: LocationManagerDelegate?

    // MARK: - Simulate
    var location: CLLocation?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined

    // MARK: - Flagler
    var isTracking: Bool = false
    private(set) var requestWhenInUseAuthorizationCalled = false
    private(set) var requestAlwaysAuthorizationCalled = false
    private(set) var startTrackingCalled = false
    private(set) var stopTrackingCalled = false
    private(set) var currentAuthorizationStatusCalled = false

    var currentLocation: CLLocation? {
        return location
    }

    // MARK: - Protocol Methods

    func requestWhenInUseAuthorization() {
        requestWhenInUseAuthorizationCalled = true
    }

    func requestAlwaysAuthorization() {
        requestAlwaysAuthorizationCalled = true
    }

    func startTracking() {
        startTrackingCalled = true
        isTracking = true
    }

    func stopTracking() {
        stopTrackingCalled = true
        isTracking = false
    }

    func currentAuthorizationStatus() -> CLAuthorizationStatus {
        currentAuthorizationStatusCalled = true
        return authorizationStatus
    }

    // MARK: - Simulate Helpers

    func simulateAuthorizationChange(to status: CLAuthorizationStatus) {
        authorizationStatus = status
        delegate?.locationManagerAuthorizationChanged(status)
    }

    func simulateLocationUpdate(latitude: Double, longitude: Double) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        self.location = location
        delegate?.locationManagerDidUpdate(self.location ?? CLLocation(latitude: 38.4192, longitude: 27.1287))
    }

    func simulateLocationFailure(with error: AppError) {
        delegate?.locationManagerDidFail(with: error)
    }

}
