//
//  JournalBottomPanel.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 03/11/24.
//
import SwiftUI

struct JournalBottomPanel : View {
    @Binding var showTagsPanel : Bool
    @Binding var showAttachmentPanel : Bool
    var body: some View {
        VStack {
            Rectangle()
                .frame(height: 0.1)
                .foregroundStyle(.secondary)
            ScrollView(.horizontal) {
                HStack {
                    Button(action: {
                        showTagsPanel.toggle()
                    }, label: {
                        Image("tag")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 24, height: 24)
                    })
                    .tint(.primary)
                    .padding(.leading, 8)
                    .padding(.trailing, 8)
                
                    Button(action: {
                        showAttachmentPanel.toggle()
                    }, label: {
                        Image("attachment")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 24, height: 24)
                    })
                    .tint(.primary)
                    .padding(.leading, 8)
                    Spacer()
                }
                .scrollDisabled(true)
            }
            
            Rectangle()
                .foregroundStyle(.secondary)
                .frame(height: 0.1)
        }
    }
}
