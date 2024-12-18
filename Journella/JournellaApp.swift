//
//  JournellaApp.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 04/10/24.
//

import SwiftUI
import SwiftData

@main
struct JournellaApp: App {
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,
//            Journal.self,
//            Tags.self
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()

    var body: some Scene {
        WindowGroup {
            JournalListView()
                .modelContainer(for:  [
                    TagMapping.self,
                    Journal.self,
                    Tags.self,
                    Item.self,
                    Attachment.self,
                    AttachmentMapping.self
                    
                ], inMemory: false, isAutosaveEnabled: true, isUndoEnabled: false, onSetup: { res in
                    //
                })
        }
        
        .environmentObject(AppDefaults.shared)
        
    }
}
