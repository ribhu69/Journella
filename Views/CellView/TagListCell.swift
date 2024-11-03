//
//  TagListCell.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 03/11/24.
//
import SwiftUI
struct TagListCell: View {
    @EnvironmentObject var appDefaults: AppDefaults
    var tag: Tags
    var onDelete: (Tags) -> Void // Callback to handle deletion

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
        .contextMenu {
            Button(role: .destructive) {
                onDelete(tag)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle()) // Makes the entire HStack tappable
    }
}
