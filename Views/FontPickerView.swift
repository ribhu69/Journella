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
    var isSelected = false
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
                    .stroke(isSelected ? Color.green : Color.gray, lineWidth: isSelected ? 0.7 : 0.4) //
            }
        }
}

struct FontPickerView : View {
    @State var textToCheck = "The quick brown fox jumps over the lazy dog "
    @State var selectedFontString = ""
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appDefaults : AppDefaults

    init() {
    }
    var body : some View {
            VStack(alignment: .leading) {
                TextField("Type something to check...", text: $textToCheck)
                    .padding(.top, 8)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    
                
                List {
                    ForEach(Fonts.allCases) { font in
                        FontPickerCell(
                            fontName: font.displayName,
                            writtenText: $textToCheck,
                            isSelected: font.displayName == selectedFontString
                        )
                            .listRowSeparator(.hidden)
                            .onTapGesture {
                                selectedFontString = font.displayName
                            }
                        
                    }
                   
                } .listStyle(.plain)
            }
            .onAppear {
                selectedFontString = AppDefaults.shared.appFontString
            }
            
            .navigationTitle("Choose Font")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Choose") {
                        if !selectedFontString.isEmpty {
                            AppDefaults.shared.setAppFont(value: selectedFontString)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .disabled(selectedFontString == appDefaults.appFontString)
                }
            }
    }
}
