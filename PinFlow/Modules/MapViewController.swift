//
//  MapViewController.swift
//  PinFlow
//
//  Created by Mine Rala on 12.05.2025.
//

import SnapKit
import MapKit
import CoreLocation

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
        let button = UIBarButtonItem(title: AppString.start.localized, style: .plain, target: self, action: #selector(toggleTracking))
        return button
    }()

    private lazy var resetButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: AppString.reset.localized, style: .plain, target: self, action: #selector(resetRoute))
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
        button.setImage(Images.location, for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(centerOnCurrentLocation), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: Properties
    private let viewModel: MapViewModelProtocol

    // MARK:  Init
    init(viewModel: MapViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupMapView()
        setupFloatingButtons()
        centerOnCurrentLocation()
        viewModel.viewDidLoad()
    }
}

// MARK: - Setup
extension MapViewController {
    private func setupMapView() {
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupNavigationBar() {
        title = AppString.navigationTitle.localized
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
    }
}

// MARK: - Private
extension MapViewController {
    private func centerMap(on location: CLLocation) {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: viewModel.defaultMapSpan, longitudinalMeters: viewModel.defaultMapSpan)
        mapView.setRegion(region, animated: true)
    }
}

// MARK: - Actions
extension MapViewController {
    @objc private func toggleTracking() {
        viewModel.toggleTracking()
       }

    @objc private func resetRoute() {
        showResetRouteConfirmation {
           self.viewModel.resetRoute()
           self.mapView.removeAnnotations(self.mapView.annotations)
        }
    }

    @objc private func centerOnCurrentLocation() {
        guard let location = viewModel.getCurrentLocation() else { return }
        centerMap(on: location)
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }

        let identifier = AppString.customAnnotationIdentifier
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
        viewModel.didSelectAnnotation(at: coordinate)
        mapView.deselectAnnotation(view.annotation, animated: true)
    }
}

// MARK: - MapViewModelDelegate
extension MapViewController: MapViewModelDelegate {
    func showErrorAlert(message: String) {
        self.showAlert(text: message, title: AppString.error.localized, buttonText: AppString.okey.localized)
    }
    
    func didFetchAddress(_ address: String) {
        DispatchQueue.main.async {
            self.showAlert(text: address, title: AppString.address.localized, buttonText: AppString.okey.localized)
        }
    }

    func addMarker(at coordinate: CLLocationCoordinate2D, isStartPoint: Bool) {
        let annotation = CustomPointAnnotation()
        annotation.coordinate = coordinate
        annotation.markerType = isStartPoint ? .start : .normal
        mapView.addAnnotation(annotation)
    }

    func setToogleTrackingButtonText(_ text: String) {
        DispatchQueue.main.async {
            self.startButton.title = text
        }
    }

    func setLocationButtonsVisibility(isVisible: Bool) {
        startButton.isEnabled = isVisible
        resetButton.isEnabled = isVisible
        locationButton.isEnabled = isVisible

        locationButtonContainer.isHidden = !isVisible
        startButton.isHidden = !isVisible
        resetButton.isHidden = !isVisible
    }

}
