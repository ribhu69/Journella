//
//  AddNote.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 05/10/24.
//
import SwiftUI
import SwiftData

struct AddJournalView: View {
    
    @EnvironmentObject var appDefaults : AppDefaults
    @Environment(\.dismiss) var dismiss
    @State var title = ""
    @Query var storedTags : [Tags]
    @State var filteredTags = [Tags]()
    @State private var startDate = Date()
    @State var titlePlaceHolder = ""
    @State var tagTitle = ""
    @State var tagTitlePlaceHolder = "Add Tags (Optional)"
    @State var nonEmptyTagsPlaceHolder = ""
    @State private var isDiscardAlertPresented: Bool = false
    @State var tags = [Tags]()
    @State var noteDescription = ""
    @State var showAddTagView = false
    @FocusState private var isTitleFocused: Bool
     @FocusState private var isJournalFocused: Bool
    @State private var isPopoverPresented = false

    
    private var journal : Journal?
    var onSave: ((Journal) -> Void)?
    

    
    init(journal: Journal? = nil, onSave: ((Journal) -> Void)?) {
        self.onSave = onSave
        if let journal {
            self.journal = journal
            self.title = journal.title
            self.noteDescription = journal.desc
            if let tags = journal.tags, !tags.isEmpty {
                self.tags = tags
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
                    
                ///Tags Area
                HStack {
                    VStack(alignment: .leading) {
                        Button(action: {
                            showAddTagView.toggle()
                        }, label: {
                            Text(tagTitlePlaceHolder)
                                .font(.body)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 8)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(.blue.opacity(0.3))
                                        
                                }
                        })
                        .tint(.secondary)
                        
                        if tags.count > 0 {
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(tags, id: \.self) { item in
                                        ItemView(text: item.title, onDelete: {
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
                    }
                    .padding(.leading, 8)
                    Spacer()
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
            .sheet(isPresented: $showAddTagView) {
                AddTagView { updatedTags in
                    tags = updatedTags
                }
            }
        }
    }
    
    private func filterTags() {
        if tagTitle.isEmpty {
            filteredTags.removeAll()
            isPopoverPresented = false
        }
        else {
            filteredTags = storedTags.filter { $0.title.localizedCaseInsensitiveContains(tagTitle)}
            isPopoverPresented = !filteredTags.isEmpty
        }
    }
    private func removeItem(_ item: Tags) {
        
        if let index = tags.firstIndex(where: { tag in
            tag.id == item.id
        }) {
            tags.remove(at: index)
        }
        
        let tagsString = tags.count > 1 ? "tags" : "tag"
        nonEmptyTagsPlaceHolder = "\(tags.count) \(tagsString) added. Add more (Optional)"
    }
    
    
    private func discard() {
        dismiss()
    }

    private func save() {
//        if !tagTitle.isEmpty {
//            let tagSplitArray = tagTitle.split(separator: ",").map {String($0)}
//            tagTitle = ""
//            tags.append(contentsOf: tagSplitArray)
//        }
////        var newNote = Note(id: uid, title: title, detail: noteDescription)
//        let newJournal = Journal(
//            id: UUID().uuidString,
//            title: title,
//            description: noteDescription,
//            createdDate: startDate
//        )
//        newJournal.tags = tags.map { Tags(title: $0, id: UUID().uuidString)}
//        onSave!(newJournal)
//        dismiss()
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
    AddJournalView() { note in
        //
    }.environmentObject(AppDefaults.shared)
}
