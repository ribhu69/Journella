//
//  JournalDetailView.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 05/10/24.
//
import SwiftUI
import SwiftData

struct JournalDetailView: View {
    
    @Environment(\.modelContext) var context
    @State private var isFirstLoad = true
    @EnvironmentObject var appDefaults : AppDefaults
    @Environment(\.colorScheme) var colorScheme
    @State var journal: Journal
    var editJournalCompleted : ((Journal) -> Void)?
    @State private var isEditMode = false
    
    init(note: Journal, editedNoteCompletion: ((Journal) -> Void)? = nil, isEditMode: Bool = false) {
        self.journal = note
        self.editJournalCompleted = editedNoteCompletion
        self.isEditMode = isEditMode
    }
    
    var body: some View {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    Text(journal.title)
                        .font(.custom(appDefaults.appFontString, size: 34, relativeTo: .body))
                        .fontWeight(.bold)
                    
                    if let tags = journal.tags, !tags.isEmpty {
                        VStack {
                            
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
                            .font(.custom(appDefaults.appFontString, size: 17, relativeTo: .body))
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 4)
                    }
                    
                    HStack {
                        Image("calender", bundle: nil)
                            .renderingMode(.template)
                            .frame(width: 25, height: 25)
                            .foregroundStyle(.secondary)
                        
                        Text(getFormattedDate(date: journal.createdDate))
                            .font(.custom(appDefaults.appFontString, size: 17, relativeTo: .body))
                        
                    }
                    
                    Text(journal.desc.isEmpty ? "No description available." : journal.desc)
                        .font(.custom(appDefaults.appFontString, size: 21, relativeTo: .body))
                        .fontWeight(.semibold)
                        .foregroundStyle(journal.desc.isEmpty ? .secondary : .primary)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                
                
               
            }
            .onAppear {
                if isFirstLoad {
                    isFirstLoad = false
                    fetchJournalAttachments()
                }
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
                
                AddJournalView(journal: journal) { (newNote) in
                    journal = newNote
                    editJournalCompleted?(newNote)
                }
            })
    }
    
    private func fetchJournalAttachments() {
        let journalId = journal.id
        let predicate = #Predicate<AttachmentMapping>{ $0.journalId == journalId}
        let attachmentMappingFD = FetchDescriptor(predicate : predicate)
        
        do {
            let attachmentMapping = try context.fetch(attachmentMappingFD)
            let attachmentIds = attachmentMapping.map {$0.attachmentId}
            
            
            let attachmentPredicate = #Predicate<Attachment>{ attachmentIds.contains($0.attachmentId) }
            let attachmentgFD = FetchDescriptor(predicate : attachmentPredicate)
            
            let attachments = try context.fetch(attachmentgFD)
            journal.attachments = attachments
            
        }
        catch {
            print(error)
        }
    }
}

struct TagView : View{
    @EnvironmentObject var appDefaults : AppDefaults
    var tag: Tags
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
        .padding(.vertical, 8)
        .contentShape(Rectangle()) // Makes the entire HStack tappable
    }
}
