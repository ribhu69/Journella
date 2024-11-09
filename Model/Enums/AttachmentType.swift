//
//  AttachmentType.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 19/10/24.
//
import Foundation

enum AttachmentTypes: String, Identifiable, CaseIterable {
    case camera
    case fileSystem
    case photoLibrary
    
    var id: String { self.rawValue } // Conformance to Identifiable
}

enum AttachmentType : String {
    
    case mp3, mp4, mov, heic, jpeg, jpg, png, pdf
    
    init(stringValue: String) {
        switch stringValue {
        case "mp3":
            self = .mp3
        case "mp4":
            self = .mp4
        case "mov":
            self = .mov
        case "heic":
            self = .heic
        case "jpeg":
            self = .jpeg
        case "jpg":
            self = .jpg
        case "png":
            self = .png
        case "pdf":
            self = .pdf
        default:
            fatalError("This value is unsupported")
        }
    }
}
