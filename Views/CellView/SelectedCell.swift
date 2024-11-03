//
//  SelectedCell.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 03/11/24.
//
import SwiftUI

struct SelectedTagCell : View {
    @EnvironmentObject var appDefaults: AppDefaults
    var tag : Tags
    var onCancel : (Tags)->Void
    var body: some View {
        HStack {
            Text("\(tag.title)")
                .font(Font.custom(appDefaults.appFontString, size: 15))
            Button(action: {
                onCancel(tag)
            }, label: {
                Image("cross", bundle: nil)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 12, height: 12)
                    .foregroundStyle(Color.red)
            })
            .tint(.primary)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(RoundedRectangle(cornerRadius: 10).foregroundStyle(tag.id.uniqueColor().opacity(0.3)))
    
    }
}
