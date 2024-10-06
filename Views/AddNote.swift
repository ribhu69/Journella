//
//  AddNote.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 05/10/24.
//
import SwiftUI

struct AddNoteView: View {
    
    @EnvironmentObject var appDefaults : AppDefaults
    @Environment(\.dismiss) var dismiss
    @State var title = ""
    @State private var startDate = Date()
    @State var titlePlaceHolder = ""
    @State var tagTitle = ""
    @State var tagTitlePlaceHolder = "Add Tags (Optional)"
    @State var nonEmptyTagsPlaceHolder = ""
    @State private var isDiscardAlertPresented: Bool = false
    @State var tags = [String]()
    @State var noteDescription = ""
    @FocusState private var isTitleFocused: Bool
     @FocusState private var isJournalFocused: Bool
    
    private var journal : Journal?
    var onSave: ((Journal) -> Void)?
    

    
    init(journal: Journal? = nil, onSave: ((Journal) -> Void)?) {
        self.onSave = onSave
        if let journal {
            self.journal = journal
            self.title = journal.title
            self.noteDescription = journal.desc
            if let tags = journal.tags, !tags.isEmpty {
                self.tags = tags.map { $0.getTagTitle() }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
              
                
                /// Header Title area
                ZStack(alignment:.leading) {
                    if self.title.isEmpty {
                        
                        TextField("Title", text: $titlePlaceHolder) {
                            isJournalFocused = true
                        } .font(.custom(appDefaults.appFontString, size: 32))
                            .padding(.horizontal, 8)
                            .foregroundColor(.primary)
                            .disabled(true)
                        
                    }
                    
                    TextField("Title", text: $title) {
                        isJournalFocused = true
                    }.font(.custom(appDefaults.appFontString, size: 32))
                        .padding(.horizontal, 8)
                        .focused($isTitleFocused)
                        .onAppear {
                            if journal != nil {
                                title = journal!.title
                            }
                            isTitleFocused = true
                            
                        }
                }
                    
                
                /// Tags Area
                VStack(alignment: .leading) {
                    ZStack(alignment:.leading) {
                        if self.tagTitle.isEmpty {
                            
                            if tags.isEmpty {
                                TextField("Test", text: $tagTitlePlaceHolder)
//                                    .font(.title3)
                                    .foregroundColor(Color(.gray))
                                    .font(.custom(appDefaults.appFontString, size: 17, relativeTo: .body))
                                    .fontWeight(.bold)
                                    .disabled(true)
                            }
                            else {
                                TextField("Test", text: $nonEmptyTagsPlaceHolder)
                                    
                                    .foregroundColor(Color(.gray))
                                    .font(.custom(appDefaults.appFontString, size: 17, relativeTo: .body))
                                    .fontWeight(.bold)

                                    .disabled(true)
                            }
                        }
                        
                        TextField("Test", text: $tagTitle)
                            .opacity(self.tagTitle.isEmpty ? 0.25 : 1)
                            .font(.custom(appDefaults.appFontString, size: 17, relativeTo: .body))
                            .foregroundColor(Color(.gray))
                            .disableAutocorrection(true)
                            .onSubmit({
                                addItem()
                            })
                        
                        
                    }
                    .padding(.horizontal, 8)
                    
                    if tags.count > 0 {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(tags, id: \.self) { item in
                                    ItemView(text: item, onDelete: {
                                        removeItem(item)
                                    })
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                        .scrollIndicators(.hidden)
                    }
                    
                    Text(getFormattedDate(date: startDate))
                        .disabled(true)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .foregroundStyle(.secondary)
                    
                        .overlay {
                            DatePicker(
                                "",
                                selection: $startDate,
                                displayedComponents: [.date]
                            )
                             .blendMode(.destinationOver)
                            
                        }
                    
                    TextField("Add description", text: $noteDescription, axis: .vertical)
                        .font(.custom(appDefaults.appFontString, size: 17, relativeTo: .body))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .focused($isJournalFocused)
                    
                }
                .onAppear {
                    if let journal,
                       
                        
                        let jTags = journal.tags,
                        !jTags.isEmpty {
                        
                        let tagsString = jTags.count > 1 ? "tags" : "tag"
                        nonEmptyTagsPlaceHolder = "\(jTags.count) \(tagsString) added. Add more (Optional)"
                        tags = jTags.map { $0.getTagTitle() }
                    }
                    noteDescription = journal?.desc ?? ""
                    
                    
                   

                }
            }
            .padding(.horizontal)
            .navigationTitle("Add Journal")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: {
                    if !title.isEmpty || !tagTitle.isEmpty {
                        isDiscardAlertPresented = true
                    } else {
                        self.discard()
                    }
                }) {
                    Text("Discard")
                },
                trailing: Button(action: {
                    // Perform save action
                    self.save()
                }) {
                    Text("Save")
                }
                .disabled(title.isEmpty)
            )
            .alert(isPresented: $isDiscardAlertPresented) {
                Alert(
                    title: Text("Discard changes?"),
                    message: Text("You have unsaved changes. Are you sure you want to discard them?"),
                   
                    primaryButton: .default(Text("Cancel")),
                    
                    secondaryButton: .destructive(Text("Discard")
                        .bold(), action: {
                        self.discard()
                    })
                )
            }
        }
    }
    private func removeItem(_ item: String) {
        if let index = tags.firstIndex(of: item) {
            tags.remove(at: index)
        }
        
        let tagsString = tags.count > 1 ? "tags" : "tag"
        nonEmptyTagsPlaceHolder = "\(tags.count) \(tagsString) added. Add more (Optional)"
    }
    
    private func addItem() {
        guard !tagTitle.isEmpty else { return }
        let tagSplitArray = tagTitle.split(separator: ",").map {String($0)}.reversed()
        tags.insert(contentsOf: tagSplitArray, at: 0)
        tagTitle = ""
        
        if tags.count > 0 {
            let tagString = tags.count > 1 ? "tags" : "tag"
            nonEmptyTagsPlaceHolder = "\(tags.count) \(tagString) added."
        }
        else {
            nonEmptyTagsPlaceHolder = ""
        }
    }
    
    private func discard() {
        dismiss()
    }

    private func save() {
        if !tagTitle.isEmpty {
            let tagSplitArray = tagTitle.split(separator: ",").map {String($0)}
            tagTitle = ""
            tags.append(contentsOf: tagSplitArray)
        }
//        var newNote = Note(id: uid, title: title, detail: noteDescription)
        let newJournal = Journal(
            id: UUID().uuidString,
            title: title,
            description: noteDescription,
            createdDate: startDate
        )
        newJournal.tags = tags.map { Tags(title: $0, id: UUID().uuidString)}
        onSave!(newJournal)
        dismiss()
    }
    
}

struct ItemView: View {
    let text: String
    let onDelete: () -> Void
    @EnvironmentObject var appDefault: AppDefaults
    var body: some View {
        HStack {
            Text(text)
                .font(.custom(appDefault.appFontString, size: 14, relativeTo: .body))
                .padding(.leading, 8)
                .padding(.vertical, 4)
            
            
            Button(action: onDelete) {
                Image(systemName: "multiply.circle.fill")
                    .foregroundColor(Color(.systemRed))
                    .imageScale(.small)
                    .padding(.vertical, 4)
                    .padding(.trailing, 8)
            }
        }
        .background(RoundedRectangle(cornerRadius: 8)
            .fill(text.uniqueColor().opacity(0.2)))
        .padding(.trailing, 8)
    }
}

#Preview {
    AddNoteView() { note in
        //
    }
}
