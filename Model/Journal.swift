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
    
}
