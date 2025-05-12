//
//  CoreDataManager.swift
//  PinFlow
//
//  Created by Mine Rala on 12.05.2025.
//


import CoreData
import CoreLocation

protocol CoreDataManaging {
    var persistentContainer: NSPersistentContainer { get }
    var context: NSManagedObjectContext { get }

    func saveContext()
    func saveLocation(latitude: Double, longitude: Double)
    func fetchAllLocations() -> [LocationModel]
    func deleteAllLocations()
}

final class CoreDataManager: CoreDataManaging {
    let persistentContainer: NSPersistentContainer

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    init(modelName: String = "LocationModel") {
        persistentContainer = NSPersistentContainer(name: modelName)
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error while loading Core Data: \(error)")
            }
        }
    }

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Core Data save error: \(error)")
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
        }
    }
}
