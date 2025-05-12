//
//  String+Ext.swift
//  PinFlow
//
//  Created by Mine Rala on 12.05.2025.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
}
