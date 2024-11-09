//
//  Untitled.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 03/11/24.
//
import SwiftData

@Model
class AttachmentMapping {
    var attachmentId: String
    var journalId: String
    
    init(attachmentId: String, journalId: String) {
        self.attachmentId = attachmentId
        self.journalId = journalId
    }
}
