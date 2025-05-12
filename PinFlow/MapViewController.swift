//
//  MapViewController.swift
//  PinFlow
//
//  Created by Mine Rala on 12.05.2025.
//

import SnapKit
import MapKit
import CoreLocation
import CoreData

final class MapViewController: UIViewController {
    private lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.delegate = self
        map.showsUserLocation = true
        map.userTrackingMode = .follow
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()

    private lazy var startButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(toggleTracking))
        return button
    }()

    private lazy var resetButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetRoute))
        return button
    }()

    private lazy var locationButtonContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.7)
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var locationButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(centerOnCurrentLocation), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var historyButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "clock.arrow.circlepath"), for: .normal)
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let locationManager = LocationManager()
    private var savedLocations: [CLLocationCoordinate2D] = []
    private let minimumDistance: CLLocationDistance = 100
    private let defaultMapSpan: CLLocationDistance = 1000

    private let coreDataManager: CoreDataManager

    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        setupNavigationBar()
        setupMapView()
        setupFloatingButtons()
        centerOnCurrentLocation()
        loadSavedLocations()
        checkLocationPermission()
    }

    // MARK: - Setup
    private func setupMapView() {
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupNavigationBar() {
        title = "Location Tracking"
        navigationItem.rightBarButtonItem = startButton
        navigationItem.leftBarButtonItem = resetButton
    }

    private func setupFloatingButtons() {
        view.addSubview(locationButtonContainer)
        locationButtonContainer.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-30)
            make.width.height.equalTo(40)
        }

        locationButtonContainer.addSubview(locationButton)
        locationButton.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }

        view.addSubview(historyButton)
        historyButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.width.height.equalTo(50)
        }
    }

    // MARK: - Actions
    @objc private func toggleTracking() {
           if locationManager.isTracking {
               locationManager.stopTracking()
               startButton.title = "Start"
           } else {
               locationManager.startTracking()
               startButton.title = "Stop"
           }
       }

    @objc private func resetRoute() {
        savedLocations.removeAll()
        mapView.removeAnnotations(mapView.annotations)
        coreDataManager.deleteAllLocations()
    }

    @objc private func centerOnCurrentLocation() {
        guard let location = locationManager.currentLocation else { return }
        centerMap(on: location)
    }


    // MARK: - Helpers
    private func checkLocationPermission() {
        switch locationManager.currentAuthorizationStatus() {
        case .notDetermined:
            // Kullanıcıdan henüz izin istenmemiş
            setLocationButtonsVisibility(isVisible: false)
            locationManager.requestWhenInUseAuthorization() // İlk olarak bu izni iste
        case .authorizedWhenInUse:
            // Kullanıcı "When In Use" izni verdi
            setLocationButtonsVisibility(isVisible: true)
            // "Always" iznini burada istemek doğru olabilir
            locationManager.requestAlwaysAuthorization() // Bu durumda "Always" izni iste
        case .authorizedAlways:
            // Kullanıcı zaten "Always" izni vermiş
            setLocationButtonsVisibility(isVisible: true)
        case .denied, .restricted:
            // İzin verilmemiş, kullanıcıyı ayarlara yönlendir
            setLocationButtonsVisibility(isVisible: false)
            showLocationPermissionAlert()
        @unknown default:
            break
        }
    }

    private func setLocationButtonsVisibility(isVisible: Bool) {
        startButton.isEnabled = isVisible
        resetButton.isEnabled = isVisible
        locationButton.isEnabled = isVisible

        locationButtonContainer.isHidden = !isVisible
        startButton.isHidden = !isVisible
        resetButton.isHidden = !isVisible
    }


    private func addMarker(at coordinate: CLLocationCoordinate2D, isStartPoint: Bool = false) {
        let annotation = CustomPointAnnotation()
        annotation.coordinate = coordinate
        annotation.markerType = isStartPoint ? .start : .normal
        mapView.addAnnotation(annotation)
    }

    private func centerMap(on location: CLLocation) {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: defaultMapSpan, longitudinalMeters: defaultMapSpan)
        mapView.setRegion(region, animated: true)
    }

    private func saveLocation(_ coordinate: CLLocationCoordinate2D) {
        // Perform Core Data operations on a background context
        let backgroundContext = coreDataManager.persistentContainer.newBackgroundContext()
        backgroundContext.perform { // Core Data üzerinde işlem yaparken kullanılan asenkron yöntem. UI thread'ini engellemez.Core data da perform daha thread safe olduğu için .global() GCD yerine kullanılıyor.
            print("Perform method entered.")
            self.coreDataManager.saveLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
    }

    private func loadSavedLocations() {
        let locations = coreDataManager.fetchAllLocations()
        savedLocations = locations.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }

        for (index, coordinate) in savedLocations.enumerated() {
            let isStart = index == 0
            addMarker(at: coordinate, isStartPoint: isStart)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: LocationManagerDelegate {

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
            self.addMarker(at: coordinate, isStartPoint: isStart)
            self.saveLocation(coordinate)
        }
    }

    func locationManagerDidFail(with error: Error) {
           print("Location Manager Error: \(error.localizedDescription)")
       }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }

        let identifier = "CustomAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }

        if let customAnnotation = annotation as? CustomPointAnnotation {
            switch customAnnotation.markerType {
            case .start:
                annotationView?.markerTintColor = .systemGreen
            case .normal:
                annotationView?.markerTintColor = .systemRed
            }
        }
        return annotationView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKUserLocation { return }
        guard let coordinate = view.annotation?.coordinate else { return }
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        Task {
            do {
                // Geocoding işlemini arka planda yapıyoruz
                let placemarks = try await CLGeocoder().reverseGeocodeLocationAsync(location)
                guard let placemark = placemarks?.first else { return }

                // Sonuç alındığında UI'yi güncelliyoruz
                let addressString = placemark.formattedAddress()

                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.showAddressAlert(address: addressString)
                    mapView.deselectAnnotation(view.annotation, animated: true)
                }
            } catch {
                print("Error occurred during geocoding: \(error)")
            }
        }
    }
}
