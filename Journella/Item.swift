//
//  Item.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 04/10/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
