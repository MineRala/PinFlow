//
//  UIViewController+Ext.swift
//  PinFlow
//
//  Created by Mine Rala on 12.05.2025.
//

import UIKit

extension UIViewController {
    func showAddressAlert(address: String) {
        let alert = UIAlertController(title: "Adres", message: address, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        self.present(alert, animated: true)
    }


    func showLocationPermissionAlert() {
        let alertController = UIAlertController(
            title: "Konum İzni Gerekli",
            message: "Uygulama, harita ve rota özelliklerini kullanabilmek için konum izni gerektiriyor. Lütfen Ayarlardan izni etkinleştirin.",
            preferredStyle: .alert
        )

        let settingsAction = UIAlertAction(title: "Ayarlar", style: .default) { _ in
            // Ayarlar sayfasına yönlendirme
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }

        let cancelAction = UIAlertAction(title: "İptal", style: .cancel)

        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }
}

