//
//  MapViewModel.swift
//  PinFlow
//
//  Created by Mine Rala on 12.05.2025.
//

import CoreLocation
import CoreData
import Combine

protocol MapViewModelDelegate: AnyObject {
    func addMarker(at coordinate: CLLocationCoordinate2D, isStartPoint: Bool)
    func setLocationButtonsVisibility(isVisible: Bool)
    func showLocationPermissionAlert()
    func setToogleTrackingButtonText(_ text: String)
    func showErrorAlert(message: String)
    func didFetchAddress(_ address: String)
}

protocol MapViewModelProtocol: AnyObject {
    var delegate: MapViewModelDelegate? { get set }
    var defaultMapSpan: CLLocationDistance { get }

    func viewDidLoad()
    func toggleTracking()
    func resetRoute()
    func getCurrentLocation() -> CLLocation?
    func didSelectAnnotation(at coordinate: CLLocationCoordinate2D)
}

final class MapViewModel: NSObject {
    weak var delegate: MapViewModelDelegate?
    private var cancellables = Set<AnyCancellable>()

    private let locationManager: LocationManagerProtocol
    private let coreDataManager: CoreDataManagerProtocol
    private var savedLocations: [CLLocationCoordinate2D] = []
    private let minimumDistance: CLLocationDistance = 100

    // MARK:  Init & Deinit
    init(locationManager: LocationManagerProtocol, coreDataManager: CoreDataManagerProtocol) {
        self.locationManager = locationManager
        self.coreDataManager = coreDataManager
        super.init()
        self.locationManager.delegate = self
        bindCoreDataErrors()
    }

    deinit {
        cancellables.forEach { $0.cancel() }
    }
}

// MARK: - Private
extension MapViewModel {
    private func bindCoreDataErrors() {
        if let coreDataManager = coreDataManager as? CoreDataManager {
            coreDataManager.errorPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] error in
                    guard let self else { return }
                    self.delegate?.showErrorAlert(message: error.userMessage)
                }
                .store(in: &cancellables)
        }
    }

    private func checkLocationPermission() {
        switch locationManager.currentAuthorizationStatus() {
        case .notDetermined:
            delegate?.setLocationButtonsVisibility(isVisible: false)
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            delegate?.setLocationButtonsVisibility(isVisible: true)
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways:
            delegate?.setLocationButtonsVisibility(isVisible: true)
        case .denied, .restricted:
            delegate?.setLocationButtonsVisibility(isVisible: false)
            delegate?.showLocationPermissionAlert()
        @unknown default:
            break
        }
    }

    private func saveLocation(_ coordinate: CLLocationCoordinate2D) {
        let backgroundContext = coreDataManager.persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            print("Perform method entered.")
            self.coreDataManager.saveLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
    }
}


// MARK: - MapViewModelProtocol
extension MapViewModel: MapViewModelProtocol {
    var defaultMapSpan: CLLocationDistance {
        1000
    }

    func viewDidLoad() {
        let locations = coreDataManager.fetchAllLocations()
        savedLocations = locations.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        for (index, coordinate) in savedLocations.enumerated() {
            let isStart = index == 0
            delegate?.addMarker(at: coordinate, isStartPoint: isStart)
        }
        checkLocationPermission()
    }
    
    func toggleTracking() {
        if locationManager.isTracking {
            locationManager.stopTracking()
            delegate?.setToogleTrackingButtonText(AppString.start.localized)
        } else {
            locationManager.startTracking()
            delegate?.setToogleTrackingButtonText(AppString.stop.localized)
        }
    }
    
    func resetRoute() {
        savedLocations.removeAll()
        coreDataManager.deleteAllLocations()
    }
    
    func getCurrentLocation() -> CLLocation? {
        return locationManager.currentLocation
    }

    func didSelectAnnotation(at coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        Task {
            do {
                let placemarks = try await CLGeocoder().reverseGeocodeLocationAsync(location)
                if let placemark = placemarks?.first {
                    let address = placemark.formattedAddress()
                    delegate?.didFetchAddress(address)
                }
            } catch {
                print("Geocoding error: \(error)")
            }
        }
    }

}

// MARK: - LocationManagerDelegate
extension MapViewModel: LocationManagerDelegate {
    func locationManagerAuthorizationChanged(_ status: CLAuthorizationStatus) {
        checkLocationPermission()
    }
    
    func locationManagerDidUpdate(_ location: CLLocation) {
        DispatchQueue.main.async {
            let coordinate = location.coordinate
            let isStart: Bool

            if let last = self.savedLocations.last {
                let lastLoc = CLLocation(latitude: last.latitude, longitude: last.longitude)
                guard location.distance(from: lastLoc) >= self.minimumDistance else { return }
                isStart = false
            } else {
                isStart = true
            }

            self.savedLocations.append(coordinate)
            self.delegate?.addMarker(at: coordinate, isStartPoint: isStart)
            self.saveLocation(coordinate)
        }
    }
    
    func locationManagerDidFail(with error: AppError) {
        delegate?.showErrorAlert(message: error.userMessage)
    }

}
