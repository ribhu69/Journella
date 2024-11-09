//
//  AddNote.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 05/10/24.
//
import SwiftUI
import SwiftData

enum FocusField : Hashable {
    case title
    case description
}

struct AddJournalView: View {
    
    @State private var selectedAttachments : [Attachment] = []
    @EnvironmentObject var appDefaults : AppDefaults
    @Environment(\.dismiss) var dismiss
    @State var title = ""
    @Query var storedTags : [Tags]
    @State var filteredTags = [Tags]()
    @State private var startDate = Date()
    @State private var isDiscardAlertPresented: Bool = false
    @State var tags : [Tags] = []
    @State var titlePlaceHolder = ""
    @State var noteDescription = ""
    @State var showAddTagView = false
    @State var showAttachmentPanel = false
    @FocusState private var focusField: FocusField?
    @State private var isPopoverPresented = false

    @State private var journalId : String?
    private var journal : Journal?
    var onSave: ((Journal) -> Void)?
    
    init(journal: Journal? = nil, onSave: ((Journal) -> Void)?) {
        self.onSave = onSave
        if let journal {
           
            self.journal = journal
            _journalId = State(initialValue: journal.id)
            _title = State(initialValue: journal.title)
            _noteDescription = State(initialValue: journal.desc)
            if let tags = journal.tags, !tags.isEmpty {
                _tags = State(initialValue: tags)
                _startDate = State(initialValue: journal.createdDate)
            }
            if let attachments = journal.attachments {
                _selectedAttachments = State(initialValue: attachments)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.vertical) {
                    /// Header Title area
                    ZStack(alignment:.leading) {
                        if self.title.isEmpty {
                            
                            TextField("Title", text: $titlePlaceHolder) {
                                focusField = .title
                            } .font(.custom(appDefaults.appFontString, size: 32))
                                .padding(.horizontal, 8)
                                .foregroundColor(.primary)
                                .disabled(true)
                            
                        }
                        
                        TextField("Title", text: $title) {
                            focusField = .description
                        }.font(.custom(appDefaults.appFontString, size: 32))
                            .padding(.horizontal, 8)
                            .focused($focusField, equals: .title)
                            .onSubmit {
                                focusField = .description
                            }
                        
                            .onAppear {
//                                if journal != nil {
//                                    title = journal!.title
//                                    noteDescription = journal!.desc
//                                    journalId = journal!.id
//                                }
                              
                                focusField = .title
                                
                            }
                    }
                        
                    ///Tags Area
                    HStack {
                        VStack(alignment: .leading) {
                            if tags.count > 0 {
                                HStack {
                                    ScrollView(.horizontal) {
                                        HStack {
                                            ForEach(tags, id: \.self) { item in
                                                SelectedTagCell(tag: item) { tag in
                                                    removeItem(tag)
                                                }
                                            }
                                        }
                                    }
                                    .scrollIndicators(.hidden)
                                    Image("tag")
                                        .resizable()
                                        .renderingMode(.template)
                                        .foregroundStyle(.secondary)
                                        .frame(width: 18, height: 18)
                                        .padding(.trailing, 4)
                                    Text("\(tags.count)")
                                        .font(.title3)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            HStack {
                                Text(getFormattedDate(date: startDate))
                                    .disabled(true)
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
                                Spacer()
                                if !selectedAttachments.isEmpty {
                                    Image("attachment")
                                        .resizable()
                                        .renderingMode(.template)
                                        .foregroundStyle(.secondary)
                                        .frame(width: 18, height: 18)
                                        .padding(.trailing, 4)
                                    Text("\(selectedAttachments.count)")
                                        .font(.title3)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                        }
                        .padding(.leading, 8)
                        Spacer()
                    }
                    
                    TextEditor(text: $noteDescription)
                        .focused($focusField, equals: .description)
                        .onSubmit {
                            focusField = nil
                        }
                        .background(Color.red)
                    
                    
                }
                .padding(.horizontal)
                JournalBottomPanel(
                    showTagsPanel: $showAddTagView,
                    showAttachmentPanel: $showAttachmentPanel)
                    .frame(maxWidth: .infinity)
            }
            
            .navigationTitle(journal != nil ? "Edit Journal" : "Add Journal")
            .navigationBarTitleDisplayMode(.inline)
            
            .navigationBarItems(
                leading: Button(action: {
                    if !title.isEmpty || !tags.isEmpty {
                        isDiscardAlertPresented = true
                    } else {
                        self.discard()
                    }
                }) {
                    Text("Discard")
                },
                trailing: HStack {
                   
                    Button(action: {
                        // Perform save action
                        self.save()
                    }) {
                        Text("Save")
                    }
                    .disabled(title.isEmpty)
                }
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
                AddTagView(existingTags: tags) { updatedTags in
                    tags = updatedTags
                }
            }
            .sheet(isPresented: $showAttachmentPanel) {
                AddAttachmentView(journalId: journalId) {
                    attachments in
                    selectedAttachments = attachments
                }
            }
        }
    }
    
  
    private func removeItem(_ item: Tags) {
        
        if let index = tags.firstIndex(where: { tag in
            tag.id == item.id
        }) {
            tags.remove(at: index)
        }
    }
    
    
    private func discard() {
        dismiss()
    }

    private func save() {
        
        
        let newTitle =  title.trimmingCharacters(in: .whitespacesAndNewlines)
        let newDescription = noteDescription.trimmingCharacters(in: .whitespacesAndNewlines)

        if let journal {
            journal.tags = tags
            journal.attachments = selectedAttachments
            journal.title = newTitle
            journal.desc = newDescription
            journal.createdDate = startDate
            onSave!(journal)
        }
        else {
            let newJournal = Journal(
                id: journalId ?? UUID().uuidString,
                title: newTitle,
                description: newDescription,
                createdDate: startDate
            )
            newJournal.tags = tags
            newJournal.attachments = selectedAttachments
            onSave!(newJournal)
        }
        dismiss()
    }
    
    
}


//#Preview {
//    AddJournalView() { note in
//        //
//    }.environmentObject(AppDefaults.shared)
//}
