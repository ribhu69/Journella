//
//  Tags.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 04/10/24.
//

import Foundation
import SwiftData

@Model
class Tags : Identifiable {
    var title : String
    var id : String
    init(title: String, id: String) {
        self.title = title
        self.id = id
    }
}

extension Tags {
    func getTagTitle() -> String {
        return title
    }
    
    static func placeholder() -> [Tags] {
        let tag1 = Tags(title: "Alpha 1", id: UUID().uuidString)
        let tag2 = Tags(title: "Beta 2", id: UUID().uuidString)
        let tag3 = Tags(title: "Gamma 3", id: UUID().uuidString)
        let tag4 = Tags(title: "Feta 4", id: UUID().uuidString)
        let tag5 = Tags(title: "Elippsis 5", id: UUID().uuidString)

        let tagsList = [tag1, tag2, tag3, tag4, tag5]
        return tagsList
    }
}
