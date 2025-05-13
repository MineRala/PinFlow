//
//  CoreDataManager.swift
//  PinFlow
//
//  Created by Mine Rala on 12.05.2025.
//


import CoreData
import CoreLocation
import Combine

protocol CoreDataManagerProtocol {
    var persistentContainer: NSPersistentContainer { get }
    var context: NSManagedObjectContext { get }

    func saveContext()
    func saveLocation(latitude: Double, longitude: Double)
    func fetchAllLocations() -> [LocationModel]
    func deleteAllLocations()
}

final class CoreDataManager {
    let persistentContainer: NSPersistentContainer
    let errorPublisher = PassthroughSubject<AppError, Never>()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    init(modelName: String = AppString.locationModel) {
        persistentContainer = NSPersistentContainer(name: modelName)
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error while loading Core Data: \(error)")
            }
        }
    }
}

// MARK: - CoreDataManagerProtocol
extension CoreDataManager: CoreDataManagerProtocol {
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Core Data save error: \(error)")
                errorPublisher.send(.saveFailed)
            }
        }
    }

    func saveLocation(latitude: Double, longitude: Double) {
        let locationEntity = LocationModel(context: context)
        locationEntity.latitude = latitude
        locationEntity.longitude = longitude
        saveContext()
    }

    func fetchAllLocations() -> [LocationModel] {
        let fetchRequest: NSFetchRequest<LocationModel> = LocationModel.fetchRequest()

        do {
            let locations = try context.fetch(fetchRequest)
            if locations.isEmpty {
                print("No locations found in Core Data.")
            }
            return locations
        } catch {
            print("Error while retrieving data: \(error)")
            errorPublisher.send(.fetchFailed)
            return []
        }
    }

    func deleteAllLocations() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = LocationModel.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            saveContext()
        } catch {
            print("Error while deleting data: \(error)")
            errorPublisher.send(.deleteFailed)
        }
    }
}
