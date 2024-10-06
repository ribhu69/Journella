//
//  NoteDetailView.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 05/10/24.
//
import SwiftUI
struct NotesDetailView: View {
    @EnvironmentObject var appDefaults : AppDefaults
    @Environment(\.colorScheme) var colorScheme
    @State var note: Journal
    var editedNoteCompletion : ((Journal) -> Void)?
    @State private var isEditMode = false
    
    init(note: Journal, editedNoteCompletion: ((Journal) -> Void)? = nil, isEditMode: Bool = false) {
        self.note = note
        self.editedNoteCompletion = editedNoteCompletion
        self.isEditMode = isEditMode
    }
    
    var body: some View {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    Text(note.title)
                        .font(.custom(appDefaults.appFontString, size: 34, relativeTo: .body))
                        .fontWeight(.bold)
                    
                    if let tags = note.tags, !tags.isEmpty {
                        VStack {
                            Text("Tags")
                                .font(.custom(appDefaults.appFontString, size: 17, relativeTo: .body))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                                .padding(.top, 4)
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(tags, id: \.self) { item in
                                        TagView(tag: item)
                                    }
                                }
                            }.frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                        }
                        .padding(.top, 4)
                        .padding(.bottom, 8)
                        
                    }
                    else {
                        Text("No tags available.")
                            .font(.custom(appDefaults.appFontString, size: 14, relativeTo: .body))
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                            .foregroundStyle(Color.gray)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 4)
                    }
                    
                    HStack {
                        Image("calender", bundle: nil)
                            .renderingMode(.template)
                            .frame(width: 25, height: 25)
                            .foregroundStyle(.secondary)
                        
                        Text(getFormattedDate(date: note.createdDate))
                            .font(.custom(appDefaults.appFontString, size: 17, relativeTo: .body))
                        
                    }
                    
                    Text(note.desc)
                        .font(.custom(appDefaults.appFontString, size: 21, relativeTo: .body))
                        .fontWeight(.semibold)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                
                
               
            }
            
            .navigationBarItems(
                trailing: HStack {
                    Button(action: {
                        isEditMode.toggle()
                    }) {
                        Image("edit", bundle: nil)
                            .renderingMode(.template)
                            .tint(colorScheme == .dark ? .white : .black)
                        
                    }
                }
            )
            .sheet(isPresented: $isEditMode, content: {
                
                AddNoteView(journal: note) { newNote in
                    note = newNote
                    editedNoteCompletion?(newNote)
                }
            })
    }
}

struct TagView : View{
    @EnvironmentObject var appDefaults : AppDefaults
    var tag: Tags
    var body: some View {
        HStack {
            Text(tag.title)
                .font(.custom(appDefaults.appFontString, size: 14, relativeTo: .body))
                .foregroundStyle(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
        }.background(RoundedRectangle(cornerRadius: 8)
            .fill(tag.id.uniqueColor().opacity(0.2)))
        
    }
}
