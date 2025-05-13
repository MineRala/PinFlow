//
//  AppError.swift
//  PinFlow
//
//  Created by Mine Rala on 12.05.2025.
//

import Foundation

enum AppError: Error {
    case saveFailed
    case fetchFailed
    case deleteFailed
    case locationDenied
    case locationUnknown
    case locationNetwork
    case genericLocationError(Error)

    var userMessage: String {
        switch self {
        case .saveFailed:
            return AppString.saveFailed.localized
        case .fetchFailed:
            return AppString.fetchFailed.localized
        case .deleteFailed:
            return AppString.deleteFailed.localized
        case .locationDenied:
            return AppString.locationDenied.localized
        case .locationUnknown:
            return AppString.locationUnknown.localized
        case .locationNetwork:
            return AppString.locationNetwork.localized
        case .genericLocationError(let error):
            return error.localizedDescription
        }
    }
}
