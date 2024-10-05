//
//  NoteDetailView.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 05/10/24.
//
import SwiftUI
struct NotesDetailView: View {
    
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
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(note.desc)
                        .font(.title2)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                
                
                if let tags = note.tags, !tags.isEmpty {
                    VStack {
                        Text("Tags")
                            .font(.title3)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                            .padding(.top, 8)
                            .padding(.horizontal, 16)
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(tags, id: \.self) { item in
                                    TagView(tag: item)
                                }
                            }
                        }.frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                            .padding(.horizontal, 16)
                    }
                    
                }
                else {
                    Text("No tags available.")
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                        .foregroundStyle(Color.gray)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                }
            }
            
            .navigationBarItems(
                trailing: HStack {
                    Button(action: {
                        isEditMode.toggle()
                    }) {
                        Image(systemName: "pencil.circle")
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
    var tag: Tags
    var body: some View {
        HStack {
            Text(tag.title)
                .font(.title3)
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
        }.background(tag.title.uniqueColor())
            .opacity(0.2)
            .cornerRadius(5)
        
    }
}
