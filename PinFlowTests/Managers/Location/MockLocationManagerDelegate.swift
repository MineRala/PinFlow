//
//  TestLocationManagerDelegate.swift
//  PinFlowTests
//
//  Created by Mine Rala on 13.05.2025.
//

import CoreLocation
@testable import PinFlow

final class MockLocationManagerDelegate: LocationManagerDelegate {
    private(set) var didChangeAuthorizationCalled = false
    private(set) var didUpdateCalled = false
    private(set) var didFailCalled = false

    private(set) var lastAuthorizationStatus: CLAuthorizationStatus?
    private(set) var lastLocation: CLLocation?
    private(set) var lastError: AppError?

    func locationManagerAuthorizationChanged(_ status: CLAuthorizationStatus) {
        didChangeAuthorizationCalled = true
        lastAuthorizationStatus = status
    }

    func locationManagerDidUpdate(_ location: CLLocation) {
        didUpdateCalled = true
        lastLocation = location
    }

    func locationManagerDidFail(with error: AppError) {
        didFailCalled = true
        lastError = error
    }
}
