//
//  FontExtension.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 06/10/24.
//

import SwiftUI

extension Font {
    static func custom(_ name: String, baseSize: CGFloat, relativeTo textStyle: Font.TextStyle) -> Font {
        // Use ScaledMetric to scale the baseSize based on textStyle
        let scaledSize = UIFontMetrics(forTextStyle: textStyle.toUIFontTextStyle()).scaledValue(for: baseSize)
        return Font.custom(name, size: scaledSize)
    }
}

extension Font.TextStyle {
    // Helper method to convert Font.TextStyle to UIFont.TextStyle
    func toUIFontTextStyle() -> UIFont.TextStyle {
        switch self {
        case .largeTitle: return .largeTitle
        case .title: return .title1
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .body: return .body
        case .callout: return .callout
        case .footnote: return .footnote
        case .caption: return .caption1
        case .caption2: return .caption2
        @unknown default: return .body
        }
    }
}
