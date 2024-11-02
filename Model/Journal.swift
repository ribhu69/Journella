//
//  Journal.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 04/10/24.
//
import Foundation
import SwiftData

@Model
class Journal : Identifiable {
    var id : String
    var title : String
    var desc : String
    var tags : [Tags]?
    var createdDate : Date
    
    init(id: String, title: String, description: String, tags: [Tags]? = nil, createdDate: Date) {
        self.id = id
        self.title = title
        self.desc = description
        self.tags = tags
        self.createdDate = createdDate
    }
}

extension Journal {
    static func sampleJournals() -> [Journal] {
            // Create some sample tags
            let sampleTags = [
                Tags(title: "Swift", id: UUID().uuidString),
                Tags(title: "Coding", id: UUID().uuidString),
                Tags(title: "Journal", id: UUID().uuidString),
                Tags(title: "Development", id: UUID().uuidString),
                Tags(title: "Learning", id: UUID().uuidString)
            ]
            
            return (1...10).map { index in
                // Randomly assign tags from sampleTags
                let randomTags = Array(sampleTags.shuffled().prefix(2)) // Get 2 random tags
                
                return Journal(
                    id: UUID().uuidString,
                    title: ["Alpha", "kasb;kasbuasd", "Irresistible", "The quick brown fox jumps overthelazydog"].randomElement()!,
                    description: "This is the description for journal entry \(index).",
                    tags: randomTags,
                    createdDate: Date()
                )
            }
        }
}
