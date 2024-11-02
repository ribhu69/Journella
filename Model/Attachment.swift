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
    var attachmentId : String
    var parentId: String
    var parentType : String
    var attachmentData : Data
    var attachmentType : String /// use `AttachmentType(stringVal: String)` initializer after fetching from database
    
    init(attachmentId: String, parentId: String, parentType: String, attachmentData: Data, attachmentType: AttachmentType) {
        self.attachmentId = attachmentId
        self.parentId = parentId
        self.parentType = parentType
        self.attachmentData = attachmentData
        self.attachmentType = attachmentType.rawValue
    }
}
