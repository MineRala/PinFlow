//
//  MockMapViewModelDelegate.swift
//  PinFlowTests
//
//  Created by Mine Rala on 13.05.2025.
//

import CoreLocation
@testable import PinFlow

final class MockMapViewModelDelegate: MapViewModelDelegate {
    private(set) var addedMarkers: [(CLLocationCoordinate2D, Bool)] = []
    private(set) var locationButtonsVisible: Bool?
    private(set) var locationPermissionAlertShown = false
    private(set) var toggleTrackingButtonText: String?
    private(set) var errorMessage: String?
    private(set) var fetchedAddress: String?

    func addMarker(at coordinate: CLLocationCoordinate2D, isStartPoint: Bool) {
        addedMarkers.append((coordinate, isStartPoint))
    }

    func setLocationButtonsVisibility(isVisible: Bool) {
        locationButtonsVisible = isVisible
    }

    func showLocationPermissionAlert() {
        locationPermissionAlertShown = true
    }

    func setToogleTrackingButtonText(_ text: String) {
        toggleTrackingButtonText = text
    }

    func showErrorAlert(message: String) {
        errorMessage = message
    }

    func didFetchAddress(_ address: String) {
        fetchedAddress = address
    }
}
