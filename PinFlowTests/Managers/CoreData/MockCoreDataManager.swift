//
//  MockCoreDataManager.swift
//  PinFlowTests
//
//  Created by Mine Rala on 13.05.2025.
//

import CoreData
import Combine
@testable import PinFlow

final class MockCoreDataManager: CoreDataManagerProtocol {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MockModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    var saveContextCalled = false
    var deleteAllLocationsCalled = false
    var saveLocationCalled = false
    var fetchAllLocationsCalled = false
    var errorPublisher = PassthroughSubject<AppError, Never>()
    var savedLocations: [LocationModel] = []

    func saveContext() {
        saveContextCalled = true
        if context.hasChanges {
            try? context.save()
        }
    }

    func saveLocation(latitude: Double, longitude: Double) {
        saveLocationCalled = true
        let entity = LocationModel(context: context)
        entity.latitude = latitude
        entity.longitude = longitude
        savedLocations.append(entity)
        saveContext()
    }

    func fetchAllLocations() -> [LocationModel] {
        fetchAllLocationsCalled = true
        return savedLocations
    }

    func deleteAllLocations() {
        deleteAllLocationsCalled = true
        savedLocations.removeAll()
        saveContext()
        // Simulate error if needed
        errorPublisher.send(.deleteFailed)
    }
}
