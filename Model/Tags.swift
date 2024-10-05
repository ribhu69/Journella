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
}
