//
//  LocationManager.swift
//  PinFlow
//
//  Created by Mine Rala on 12.05.2025.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate: AnyObject {
    func locationManagerAuthorizationChanged(_ status: CLAuthorizationStatus)
    func locationManagerDidUpdate(_ location: CLLocation)
    func locationManagerDidFail(with error: Error)
}

final class LocationManager: NSObject {
    private let manager = CLLocationManager()
    public weak var delegate: LocationManagerDelegate?

    private(set) var isTracking: Bool = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
    }


    func requestWhenInUseAuthorization() {
         manager.requestWhenInUseAuthorization()
     }

     func requestAlwaysAuthorization() {
         manager.requestAlwaysAuthorization()
     }

     func startTracking() {
         manager.startUpdatingLocation()
         isTracking = true
     }

     func stopTracking() {
         manager.stopUpdatingLocation()
         isTracking = false
     }

     func currentAuthorizationStatus() -> CLAuthorizationStatus {
         return manager.authorizationStatus
     }

     var currentLocation: CLLocation? {
         return manager.location
     }

}


extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        delegate?.locationManagerAuthorizationChanged(manager.authorizationStatus)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        delegate?.locationManagerDidUpdate(latest)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.locationManagerDidFail(with: error)
    }
}
