//
//  FontEnum.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 04/10/24.
//

enum Fonts : Identifiable, Hashable, CaseIterable {
    var id: Fonts {
        return self
    }
    case roboto
    case playFair
    case dancingScript
    case oswald
}

extension Fonts {
    var displayName: String {
        switch self {
        case .roboto:
            return "Roboto"
        case .playFair:
            return "Playfair Display"
        case .dancingScript:
            return "Dancing Script"
        case .oswald:
            return "Oswald"
        }
    }
}
