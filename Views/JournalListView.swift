//
//  FontListView.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 04/10/24.
//

import SwiftUI
import SwiftData
struct JournalRow: View {
    @EnvironmentObject var appDefaults: AppDefaults
    var journal: Journal
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(journal.title)
                    .lineLimit(1)
                    .font(Font.custom(appDefaults.appFontString, size: 24))
                Spacer()
                Image("calender", bundle: nil)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 14, height: 14)
                    .foregroundStyle(.secondary)
                    .padding(.trailing, 4)
                Text(getFormattedDate(date: journal.createdDate))
                    .font(Font.custom(appDefaults.appFontString, size: 14))
                    .foregroundStyle(.secondary)
            }
           
               
            Text(journal.desc.isEmpty ? "No Description" : journal.desc)
                .lineLimit(2)
                .foregroundStyle(.secondary)
                .font(Font.custom(appDefaults.appFontString, size: 18))
            
            if let tags = journal.tags, !tags.isEmpty  {
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
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
}

struct JournalCollectionView: View {
    var journal: Journal
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appDefaults: AppDefaults

    var body: some View {
        NavigationLink(destination: {
            JournalDetailView(note: journal)
        }, label: {
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
        })
        .padding()
        .background(colorScheme == .dark ? Color(.systemGray6) : Color.white) // Dynamic background color
        .cornerRadius(15) // Smooth corner radius for the card shape
        .shadow(color: colorScheme == .dark ?
                Color.white.opacity(0.2) :
                    Color.black.opacity(0.2), radius: 4, x: 2, y: 3) // Dynamic shadow color
        .tint(.primary)
    }
}

struct BreatheAnimationView: View {
    @State private var breatheInOut = false

    var body: some View {
        VStack {
            Image(systemName: "heart")
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)
            Text("Start typing, let your thoughts take flight.")
                .foregroundStyle(.secondary)
        }
        
    }
}

struct JournalListView : View {
    @State private var showDeleteAlert = false
    @EnvironmentObject var appDefaults: AppDefaults
    @Environment(\.modelContext) private var context
    @Query var journals : [Journal]
    @State var recentJournals : [Journal] = []
    @State var showSettingsPage = false
    @State var showWriteJournalView = false
    @State var showEditJournalView = false
    @State private var journalInEdit : Journal?
    @State private var journalToDelete: Journal?
    @Environment(\.colorScheme) var colorScheme
    @State private var searchText = ""
    var filteredJournals: [Journal] {
            if searchText.isEmpty {
                return journals
            } else {
                return journals.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.desc.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
  
    var body: some View {
        
        NavigationView {
            VStack {
                
                if !searchText.isEmpty {
                    if !filteredJournals.isEmpty {
                        List {
                            ForEach(filteredJournals) { journal in
                                
                                NavigationLink {
                                    JournalDetailView(note: journal) { editedJournal in
                                        deleteJournal(journal: journal)
                                        context.insert(editedJournal)
                                        recentJournals.insert(editedJournal, at: 0)
                                    }
                                } label: {
                                    JournalRow(journal: journal)
                                        .padding(.bottom, 8)
                                        .padding(.horizontal, 8)
                                       
                                        .frame(maxWidth: .infinity) // Ensure the entire row is tappable
                                        .contentShape(Rectangle()) // Make the whole row area responsive to taps
                                }
                            }
                        }
                    }
                    else {
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
                else {
                    if journals.count > 0 {
                        List {
                            
                            if recentJournals.count > 5 {
                                Section {
                                    VStack(alignment: .leading) {
                                        Text("Recent Journals")
                                            .multilineTextAlignment(.leading)
                                            .foregroundStyle(.secondary)
                                        HStack {
                                            
                                            ScrollView(.horizontal) {
                                                HStack {
                                                    ForEach(journals) { journal in
                                                        JournalCollectionView(journal: journal)
                                                        
                                                            .frame(maxWidth: UIScreen.main.bounds.width / 3)
                                                            .padding(4)
                                                    }
                                                    
                                                }
                                            }
                                        }
                                        .padding(.bottom, 8)
                                    }
                                    .padding(.horizontal, 8)
                                }
                            }
                            
                            ForEach(journals) { journal in
                                
                                NavigationLink {
                                    JournalDetailView(note: journal) { editedJournal in
                                        deleteJournal(journal: journal)
                                        context.insert(editedJournal)
                                        recentJournals.insert(editedJournal, at: 0)
                                    }
                                } label: {
                                    JournalRow(journal: journal)
                                        .padding(.bottom, 8)
                                        .padding(.horizontal, 8)
                                        .contextMenu {
                                            Button(action: {
                                                journalInEdit = journal
                                            }) {
                                                Label("Edit", systemImage: "pencil")
                                            }
                                            
                                            Button(action: {
                                                deleteJournal(journal: journal)
                                            }) {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                        .frame(maxWidth: .infinity) // Ensure the entire row is tappable
                                        .contentShape(Rectangle()) // Make the whole row area responsive to taps
                                }
                            }
                        }
                    }
                    else {
                        BreatheAnimationView()
                    }
                }
                
            }
            .sheet(isPresented: $showWriteJournalView) {
                AddJournalView { journal in
                    context.insert(journal)
                    recentJournals.insert(journal, at: 0)
                    do {
                        try context.save()
                    }
                    catch {
                        fatalError()
                    }
                }
            }
            .sheet(isPresented: $showEditJournalView) {
                AddJournalView(journal: journalInEdit!) { updatedJournal in
                    deleteJournal(journal: journalInEdit!)
                    context.insert(updatedJournal)
                    recentJournals.insert(updatedJournal, at: 0)
                }
            }
            .fullScreenCover(isPresented: $showSettingsPage, content: {
                SettingsView()
            })
            
            .onAppear {
                recentJournals = journals
            }
            
            .onChange(of: journalInEdit) { oldVal, newVal in
                if newVal != nil {
                    showEditJournalView = true
                }
            }
          
            .navigationTitle("Journella")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showWriteJournalView.toggle()
                    }) {
                        Image("write", bundle: nil)
                            .renderingMode(.template)
                            .tint(colorScheme == .dark ? .white : .black)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            showSettingsPage.toggle()
                        }) {
                            Image("HomeSetting", bundle: nil)
                                .renderingMode(.template)
                                .tint(colorScheme == .dark ? .white : .black)
                        }

                }
            }
            .alert(isPresented: $showDeleteAlert) {
                       Alert(
                           title: Text("Confirm Deletion"),
                           message: Text("Are you sure you want to delete this journal? This action cannot be undone."),
                           primaryButton: .destructive(Text("Delete")) {
                               if let journal = journalToDelete {
                                   performDelete(journal: journal)
                               }
                           },
                           secondaryButton: .cancel() {
                               journalToDelete = nil
                           }
                       )
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
    
    func performDelete(journal: Journal) {
            withAnimation {
                context.delete(journal)
                recentJournals.removeAll { $0.id == journal.id }
                journalToDelete = nil
                do {
                    try context.save()
                } catch {
                    fatalError("Failed to save context after deletion: \(error)")
                }
            }
        }
}

#Preview {
    JournalListView().environmentObject(AppDefaults.shared)
}
