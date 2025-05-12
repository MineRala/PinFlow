//
//  CLGeocoder+Ext.swift
//  PinFlow
//
//  Created by Mine Rala on 12.05.2025.
//

import CoreLocation

extension CLGeocoder {
    func reverseGeocodeLocationAsync(_ location: CLLocation) async throws -> [CLPlacemark]? {
        try await withCheckedThrowingContinuation { continuation in
            reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: placemarks)
                }
            }
        }
    }
}
