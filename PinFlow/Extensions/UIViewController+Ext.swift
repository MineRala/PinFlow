//
//  UIViewController+Ext.swift
//  PinFlow
//
//  Created by Mine Rala on 12.05.2025.
//

import UIKit

extension UIViewController {
    func showAlert(text: String, title: String, buttonText: String) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonText, style: .default))
        self.present(alert, animated: true)
    }

    func showLocationPermissionAlert() {
        let alertController = UIAlertController(
            title: AppString.privacyTitle.localized,
            message: AppString.privacyMessage.localized,
            preferredStyle: .alert
        )

        let settingsAction = UIAlertAction(title: AppString.settings.localized, style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }

        let cancelAction = UIAlertAction(title: AppString.cancel.localized, style: .cancel)

        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }

    func showResetRouteConfirmation(onConfirm: @escaping () -> Void) {
        let alert = UIAlertController(
            title: AppString.resetRoute.localized,
            message: AppString.confirmResetRoute.localized,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: AppString.cancel.localized, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: AppString.yes.localized, style: .destructive) { _ in
            onConfirm()
        })

        present(alert, animated: true)
    }
}

