//
//  FontPickerView.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 04/10/24.
//

import SwiftUI

struct FontPickerCell : View {
    var fontName : String
    @Binding var writtenText : String
    @ScaledMetric(relativeTo: .body) var dynamicSize = 24
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(fontName)
                    .foregroundStyle(.secondary)
                    
                Text(writtenText.isEmpty ? fontName : writtenText)
                    .font(Font.custom(fontName, size: dynamicSize))
                    .animation(.easeInOut, value: writtenText)
                    .padding(.top, 4)
            }
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
            .frame(maxWidth: .infinity)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 0.4) //
            }
        }
}

struct FontPickerView : View {
    @State var textToCheck = "The quick brown fox jumps over the lazy dog "
    
    var body : some View {
        NavigationView {
            VStack(alignment: .leading) {
                TextField("Type something to check...", text: $textToCheck)
                    .padding(.top, 8)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    
                
                List {
                    ForEach(Fonts.allCases) { font in
                        FontPickerCell(fontName: font.displayName, writtenText: $textToCheck)
                            .listRowSeparator(.hidden)
                    }
                   
                } .listStyle(.plain)
            }
            
            .navigationTitle("Choose Font")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        //cancelAction
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Choose") {
                        //cancelAction
                    }
                }
            }
        }
       
    }
}

#Preview {
    FontPickerView(textToCheck: "The quick brown fox jumps over the lazy dog")
}
