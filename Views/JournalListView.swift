//
//  FontListView.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 04/10/24.
//

import SwiftUI
import SwiftData

enum DataState {
    case loading, loaded
}

struct JournalRow: View {
    @EnvironmentObject var appDefaults: AppDefaults
    var journal: Journal
    
    var body: some View {
        VStack(alignment: .leading) {
            journalHeader
            journalDescription
            journalTags
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var journalHeader: some View {
        HStack {
            Text(journal.title)
                .lineLimit(1)
                .font(.custom(appDefaults.appFontString, size: 24))
            Spacer()
            Image("calender", bundle: nil)
                .resizable()
                .renderingMode(.template)
                .frame(width: 14, height: 14)
                .foregroundStyle(.secondary)
                .padding(.trailing, 4)
            Text(getFormattedDate(date: journal.createdDate))
                .font(.custom(appDefaults.appFontString, size: 14))
                .foregroundStyle(.secondary)
        }
    }
    
    private var journalDescription: some View {
        Text(journal.desc.isEmpty ? "No Description" : journal.desc)
            .lineLimit(2)
            .foregroundStyle(.secondary)
            .font(.custom(appDefaults.appFontString, size: 18))
    }
    
    private var journalTags: some View {
        Group {
            if let tags = journal.tags, !tags.isEmpty {
                HStack {
                    Image("tag", bundle: nil)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(.secondary)
                        .frame(width: 18, height: 18)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(tags) { tag in
                                TagView(tag: tag)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct JournalCollectionView: View {
    var journal: Journal
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appDefaults: AppDefaults
    
    var body: some View {
        NavigationLink(destination: JournalDetailView(note: journal)) {
            VStack(alignment: .leading) {
                Text(journal.title)
                    .font(.custom(appDefaults.appFontString, size: 21))
                    .padding(.bottom, 4)
                    .foregroundStyle(.primary)
                Text(journal.desc.isEmpty ? "No Description" : journal.desc)
                    .lineLimit(2)
                    .font(.custom(appDefaults.appFontString, size: 18))
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color(.systemGray6) : Color.white)
        .cornerRadius(15)
        .shadow(color: colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.2), radius: 4, x: 2, y: 3)
        .tint(.primary)
    }
}

// Main ListView
struct JournalListView: View {
    
    @State private var isFirstTime = true
    @State private var showDeleteAlert = false
    @EnvironmentObject var appDefaults: AppDefaults
    @Environment(\.modelContext) private var context
    @State var journals : [Journal] = []
    @State private var recentJournals: [Journal] = []
    @State private var showSettingsPage = false
    @State private var showWriteJournalView = false
    @State private var showEditJournalView = false
    @State private var journalInEdit: Journal?
    @State private var journalToDelete: Journal?
    @Environment(\.colorScheme) var colorScheme
    @State private var searchText = ""
    @State private var dataState : DataState = .loading

    var filteredJournals: [Journal] {
        if searchText.isEmpty {
            return journals
        } else {
            return journals.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.desc.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                content
            }
            .sheet(isPresented: $showWriteJournalView) {
                AddJournalView { journal in
                    updateTags(for: journal)
                    context.insert(journal)
                    saveJournalAttachments(journal: journal)
                    recentJournals.insert(journal, at: 0)
                    journals.insert(journal, at: 0)
                    saveContext()
                    
                }
            }
            .sheet(isPresented: $showEditJournalView) {
                AddJournalView(journal: journalInEdit!) { updatedJournal in
                    editAndSaveJournal(journal: updatedJournal)
                }
            }
            .fullScreenCover(isPresented: $showSettingsPage) {
                SettingsView()
            }
            .onAppear {
                
                if isFirstTime {
                    isFirstTime = false
                    fetchJournals()
                    recentJournals = journals
                }

            }
            .onChange(of: journalInEdit) { oldVal, newVal in
                showEditJournalView = newVal != nil
            }
            .navigationTitle("Journella")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))
            .toolbar { toolbarContent }
            .alert(isPresented: $showDeleteAlert) { deleteAlert }
        }
    }
    
    private var content: some View {
        Group {
            if searchText.isEmpty {
                journalsList
            } else {
                searchResults
            }
        }
    }
    
    private var journalsList: some View {
        
        Group {
            if journals.isEmpty {
                if dataState == .loading {
                    emptyLoadingStateView
                }
                else {
                    emptyListView
                }
                
            }
            else {
                List {
                    ForEach(journals) { journal in
                        NavigationLink(destination: JournalDetailView(note: journal)) {
                            JournalRow(journal: journal)
                                .padding(.bottom, 8)
                                .padding(.horizontal, 8)
                                .contextMenu { contextMenuButtons(for: journal) }
                                .frame(maxWidth: .infinity)
                                .contentShape(Rectangle())
                        }
                    }
                }
            }
        }
       
    }
    
    private var searchResults: some View {
        Group {
            if filteredJournals.isEmpty {
                emptyStateView
            } else {
                List(filteredJournals, id: \.id) { journal in
                    NavigationLink(destination: JournalDetailView(note: journal)) {
                        JournalRow(journal: journal)
                            .padding(.bottom, 8)
                            .padding(.horizontal, 8)
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            Image("empty")
                .renderingMode(.template)
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundStyle(.secondary)
            Text("Uh-oh! Looks like the journal's on a ☕️ break.\nTry again later!")
                .multilineTextAlignment(.center)
                .padding(.top, 4)
            Spacer()
        }
    }
    
    private var emptyListView: some View {
        VStack {
            Spacer()
            Image(systemName: "heart")
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)
            Text("Start typing, let your thoughts take flight.")
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
    
    private var emptyLoadingStateView: some View {
        VStack {
            Spacer()
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5) // Adjust size if needed
                .padding()
            
            Text("Loading Journals...")
                .font(.headline)
                .foregroundColor(.gray)
            
            Spacer()
        }
    }
    
    private var deleteAlert: Alert {
        Alert(
            title: Text("Confirm Deletion"),
            message: Text("Are you sure you want to delete this journal? This action cannot be undone."),
            primaryButton: .destructive(Text("Delete")) {
                if let journal = journalToDelete {
                    performDelete(journal: journal)
                }
            },
            secondaryButton: .cancel { journalToDelete = nil }
        )
    }
    
    private func contextMenuButtons(for journal: Journal) -> some View {
        Group {
            Button(action: { journalInEdit = journal }) {
                Label("Edit", systemImage: "pencil")
            }
            Button(action: { deleteJournal(journal: journal) }) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showWriteJournalView.toggle() }) {
                    Image("write", bundle: nil)
                        .renderingMode(.template)
                        .tint(colorScheme == .dark ? .white : .black)
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { showSettingsPage.toggle() }) {
                    Image("HomeSetting", bundle: nil)
                        .renderingMode(.template)
                        .tint(colorScheme == .dark ? .white : .black)
                }
            }
        }
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    // Other functions remain the same
    func updateTags(for journal: Journal) {
        let journalId = journal.id
        let predicate = #Predicate<TagMapping> { $0.mappedJournalId == journalId }
        let fetchDescriptor = FetchDescriptor(predicate: predicate)
        do {
            let items = try context.fetch(fetchDescriptor)
            if !items.isEmpty {
                for item in items {
                    context.delete(item)
                }
            }
            if let tags = journal.tags {
                
                for tag in tags {
                    let newTagMap = TagMapping(tagId: tag.id, mappedJournalId: journal.id)
                    context.insert(newTagMap)
                }
            }
            try context.save()
        }
        catch {
            print(error)
        }
    }
    
    func saveJournalAttachments(journal: Journal) {
        
            if let attachments = journal.attachments {
                do {
                    for item in attachments {
                        item.parentId = journal.id
                        context.insert(AttachmentMapping(attachmentId: item.attachmentId, journalId: journal.id))
                        context.insert(item)
                    }
                    try context.save()
                }
                catch {
                    print(error)
                }
            }
    }
    
    func performDelete(journal: Journal) {
        withAnimation {
            context.delete(journal)
            let journalId = journal.id
            recentJournals.removeAll { $0.id == journalId }
            journals.removeAll { $0.id == journalId }
            journalToDelete = nil
            
            
            //Delete tags and their mapping.
            let predicate = #Predicate<TagMapping> { $0.mappedJournalId == journalId }
            let fetchDescriptor = FetchDescriptor(predicate: predicate)
            do {
                let items = try context.fetch(fetchDescriptor)
                if !items.isEmpty {
                    for item in items {
                        context.delete(item)
                    }
                }
                try context.save()
            }
            
            catch {
                fatalError("Failed to save context after deletion: \(error)")
            }
            
            //Delete tags and their mapping.
            let attachmentMappingPredicate = #Predicate<AttachmentMapping> { $0.journalId == journalId }
            let attachmentMappingFD = FetchDescriptor(predicate: attachmentMappingPredicate)
            do {
                let items = try context.fetch(attachmentMappingFD)
                if !items.isEmpty {
                    for item in items {
                        context.delete(item)
                    }
                }
                try context.save()
            }
            
            catch {
                fatalError("Failed to save context after deletion: \(error)")
            }
            
            //Delete tags and their mapping.
            let attachmentsPredicate = #Predicate<Attachment> { $0.parentId == journalId }
            let attachmentFD = FetchDescriptor(predicate: attachmentsPredicate)
            do {
                let items = try context.fetch(attachmentFD)
                if !items.isEmpty {
                    for item in items {
                        context.delete(item)
                    }
                }
                try context.save()
            }
            
            catch {
                fatalError("Failed to save context after deletion: \(error)")
            }
        }
    }
    
    func deleteJournal(journal: Journal) {
        let isPromptEnabled = AppDefaults.shared.isDeletePromptEnabled()
        
        if isPromptEnabled {
            journalToDelete = journal
            showDeleteAlert = true    // Show the alert
        } else {
            performDelete(journal: journal) // Directly delete if prompt is disabled
        }
    }
    
    func editAndSaveJournal(journal: Journal) {
        deleteExistingAttachments(journal: journal)
        deleteJournal(journal: journalInEdit!)
        updateTags(for: journal)
        context.insert(journal)
        saveJournalAttachments(journal: journal)
        recentJournals.insert(journal, at: 0)
    }
    
    func fetchJournals() {
        let fetchDescriptor = FetchDescriptor<Journal>()
        do {
            journals = try context.fetch(fetchDescriptor)
            recentJournals = journals
            dataState = .loaded
        }
        
        catch {
            print(error)
        }
    }
    
    private func deleteExistingAttachments(journal: Journal) {
        let journalId = journal.id
        let predicate = #Predicate<Attachment> { $0.parentId == journalId }
        let fetchDescriptor = FetchDescriptor(predicate: predicate)
        do {
            let existingAttachments = try context.fetch(fetchDescriptor)
            for item in existingAttachments {
                context.delete(item)
            }
        }
        catch {
            print(error)
        }
    }
}


#Preview {
    JournalListView().environmentObject(AppDefaults.shared)
}
