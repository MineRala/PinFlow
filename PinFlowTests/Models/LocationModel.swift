//
//  LocationModel.swift
//  PinFlowTests
//
//  Created by Mine Rala on 13.05.2025.
//

@testable import PinFlow
import CoreData

extension LocationModel {
    static func mock(latitude: Double, longitude: Double, context: NSManagedObjectContext) -> LocationModel {
        let entity = LocationModel(context: context)
        entity.latitude = latitude
        entity.longitude = longitude
        return entity
    }
}
