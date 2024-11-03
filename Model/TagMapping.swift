//
//  TagMapping.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 03/11/24.
//
import SwiftData

@Model
class TagMapping : Identifiable {
    var tagId : String
    var mappedJournalId : String
    
    init(tagId: String, mappedJournalId: String) {
        self.tagId = tagId
        self.mappedJournalId = mappedJournalId
    }
}
