//
//  ColorExtension.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 04/10/24.


import SwiftUI

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}


extension String {
    /// Generates a consistent color based on the string's unique hash
    func uniqueColor() -> Color {
        // Hash the string
        let hash = self.hash
        
        // Create RGB values from the hash
        let red = Double((hash & 0xFF0000) >> 16) / 255.0
        let green = Double((hash & 0x00FF00) >> 8) / 255.0
        let blue = Double(hash & 0x0000FF) / 255.0
        
        // Return a SwiftUI Color
        return Color(red: red, green: green, blue: blue)
    }
}
