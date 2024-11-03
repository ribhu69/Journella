//
//  TagCell.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 03/11/24.
//
import SwiftUI

struct TagCell : View {
    @EnvironmentObject var appDefaults: AppDefaults
    var tag: Tags
    var onSelect: (Tags) -> Void
    
    var body: some View {
        HStack {
            Text("\(tag.title)")
                .font(Font.custom(appDefaults.appFontString, size: 15))
                .tint(.primary)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(RoundedRectangle(cornerRadius: 10).foregroundStyle(tag.id.uniqueColor().opacity(0.3)))
            
            Spacer()
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle()) // Makes the entire HStack tappable
        .onTapGesture {
            onSelect(tag)
        }
    }
}
