//
//  Attachment.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 19/10/24.
//
import Foundation
import SwiftData

@Model
final class Attachment {
    var attachmentId: String
    var parentId: String?
    var parentType: String
    var attachmentData: Data
    var attachmentTitle: String
    var attachmentType: String  // Use `AttachmentType(stringVal: String)` initializer after fetching from database
    var attachmentSize: Double
    var createdAt: Date

    init(
        attachmentId: String,
        parentType: String,
        attachmentData: Data,
        attachmentTitle: String,
        attachmentType: AttachmentType,
        attachmentSize: Double,
        createdAt: Date
    ) {
        self.attachmentId = attachmentId
        self.parentType = parentType
        self.attachmentData = attachmentData
        self.attachmentTitle = attachmentTitle
        self.attachmentType = attachmentType.rawValue
        self.attachmentSize = attachmentSize
        self.createdAt = createdAt
    }
}

extension Attachment {
    static func samples() -> [Attachment] {
        let sampleAttachments: [Attachment] = [
            Attachment(
                attachmentId: "1",
               
                parentType: "Post",
                attachmentData: Data("Sample Image Data".utf8),
                attachmentTitle: "Vacation Photo",
                attachmentType: .jpeg,
                attachmentSize: 1.5,  // in MB, for example
                createdAt: Date()
            ),
            Attachment(
                attachmentId: "2",
                parentType: "Comment",
                attachmentData: Data("Sample Video Data".utf8),
                attachmentTitle: "Birthday Video",
                attachmentType: .mov,
                attachmentSize: 50.0,  // in MB
                createdAt: Date()
            ),
            Attachment(
                attachmentId: "3",
                parentType: "Message",
                attachmentData: Data("Sample Document Data".utf8),
                attachmentTitle: "Project Report",
                attachmentType: .pdf,
                attachmentSize: 0.3,  // in MB
                createdAt: Date()
            ),
            Attachment(
                attachmentId: "4",
                parentType: "Note",
                attachmentData: Data("Sample Audio Data".utf8),
                attachmentTitle: "Meeting Audio",
                attachmentType: .mp3,
                attachmentSize: 5.0,  // in MB
                createdAt: Date()
            ),
            Attachment(
                attachmentId: "5",
                parentType: "Note",
                attachmentData: Data("Sample Audio Data".utf8),
                attachmentTitle: "Lecture Recording",
                attachmentType: .mp4,
                attachmentSize: 30.0,  // in MB
                createdAt: Date()
            )
        ]
        return sampleAttachments
    }
}
