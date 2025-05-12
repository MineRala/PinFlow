//
//  CLPlacemark+Ext.swift
//  PinFlow
//
//  Created by Mine Rala on 12.05.2025.
//

import CoreLocation

extension CLPlacemark {
    func formattedAddress() -> String {
        var addressString = ""

        if let name = self.name { addressString += "📍 \(AppString.place.localized) \(name)\n" }
        if let thoroughfare = self.thoroughfare { addressString += "🏠 \(AppString.street.localized) \(thoroughfare)\n" }
        if let subThoroughfare = self.subThoroughfare { addressString += "🔢 \(AppString.doorNumber.localized) \(subThoroughfare)\n" }
        if let locality = self.locality { addressString += "🏘 \(AppString.locality.localized) \(locality)\n" }
        if let subLocality = self.subLocality { addressString += "🏡 \(AppString.subLocality.localized) \(subLocality)\n" }
        if let administrativeArea = self.administrativeArea { addressString += "🏢 \(AppString.province.localized) \(administrativeArea)\n" }
        if let postalCode = self.postalCode { addressString += "📮 \(AppString.postalCode.localized) \(postalCode)\n" }
        if let country = self.country { addressString += "🌍 \(AppString.country.localized) \(country)\n" }

        return addressString
    }
}
