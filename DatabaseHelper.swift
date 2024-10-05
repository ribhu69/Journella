//
//  DatabaseHelper.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 05/10/24.
//
import SwiftData
import Foundation

class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    static private let schema = Schema(
        [
            Item.self,
            Journal.self,
            Tags.self
        ]
    )
    var context : ModelContext!
    let storeURL = URL.documentsDirectory.appending(path: "database.sqlite")

    private var sharedContainer : ModelContainer!
    private init() {
        setupContext()
    }
    
    private func setupContext() {
        let storeURL = URL.applicationSupportDirectory.appending(path: "default.store")
        var container: ModelContainer!

        // Check if the file exists at the specified location
        
        if FileManager.default.fileExists(atPath: storeURL.path) {
            do {
                let config = ModelConfiguration(url: storeURL)
                container = try ModelContainer(for: DatabaseManager.schema, configurations: config)
            } catch {
                print("Failed to create model container with existing file: \(error)")
                // Handle the error appropriately if needed
            }
        } else {
            // File not found, handle it in the catch block
            do {
                let modelConfiguration = ModelConfiguration(schema: DatabaseManager.schema, isStoredInMemoryOnly: false)
                container = try ModelContainer(for: DatabaseManager.schema, configurations: [modelConfiguration])
            } catch {
                print("Failed to create model container with new configuration: \(error)")
                // Handle the error appropriately
            }
        }

        self.sharedContainer = container
        self.context = .init(container)
    }


    func getModelContext() -> ModelContext {
        return context
    }
    
    func getContainer() -> ModelContainer {
        return sharedContainer
    }
}
