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

        if let name = self.name { addressString += "📍 Yer: \(name)\n" }
        if let thoroughfare = self.thoroughfare { addressString += "🏠 Cadde: \(thoroughfare)\n" }
        if let subThoroughfare = self.subThoroughfare { addressString += "🔢 Kapı No: \(subThoroughfare)\n" }
        if let locality = self.locality { addressString += "🏘 İlçe: \(locality)\n" }
        if let subLocality = self.subLocality { addressString += "🏡 Semt: \(subLocality)\n" }
        if let administrativeArea = self.administrativeArea { addressString += "🏢 İl: \(administrativeArea)\n" }
        if let postalCode = self.postalCode { addressString += "📮 Posta Kodu: \(postalCode)\n" }
        if let country = self.country { addressString += "🌍 Ülke: \(country)\n" }

        return addressString
    }
}
