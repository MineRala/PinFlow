//
//  AppDelegate.swift
//  PinFlow
//
//  Created by Mine Rala on 12.05.2025.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        let window = UIWindow(frame: UIScreen.main.bounds)
        let coreDataManager: CoreDataManagerProtocol = CoreDataManager()
        let locationManager: LocationManagerProtocol = LocationManager()
        let mapViewModel = MapViewModel(locationManager: locationManager, coreDataManager: coreDataManager)
        let mapViewController = MapViewController(viewModel: mapViewModel)
        let navController = UINavigationController(rootViewController: mapViewController)

        window.rootViewController = navController
        window.makeKeyAndVisible()
        self.window = window

        return true
    }
}
