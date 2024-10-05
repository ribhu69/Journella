//
//  FontListView.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 04/10/24.
//

import SwiftUI
import SwiftData
struct JournalRow: View {
    var journal: Journal
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(journal.title)
                .font(.title3)
            
            Text(journal.desc.isEmpty ? "No Description" : journal.desc)
                .lineLimit(2)
                .foregroundStyle(.secondary)
            
            Text(getFormattedDate(date: journal.createdDate))
                .foregroundStyle(.secondary)
            
            
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
                                Text(tag.title)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(tag.id.uniqueColor().opacity(0.2)) // The color applied as background
                                    )
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
    var body: some View {
        VStack(alignment: .leading) {
            Text(journal.title)
                .font(.title3)
                .padding(.bottom, 4)
            Text(journal.desc.isEmpty ? "No Description" : journal.desc)
                .lineLimit(2)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(colorScheme == .dark ? Color(.systemGray6) : Color.white) // Dynamic background color
        .cornerRadius(15) // Smooth corner radius for the card shape
        .shadow(color: colorScheme == .dark ?
                Color.white.opacity(0.2) :
                    Color.black.opacity(0.2), radius: 4, x: 2, y: 3) // Dynamic shadow color
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
    
    @Environment(\.modelContext) private var context
    @Query var journals : [Journal]
    @State var recentJournals : [Journal] = []
    
    @State var showWriteJournalView = false
    @State var showEditJournalView = false
    @State private var journalInEdit : Journal?
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        
        NavigationView {
            VStack {
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
                                NotesDetailView(note: journal) { editedJournal in
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
                                        
                                        Button(action: {
                                            print("Share \(journal.title)")
                                        }) {
                                            Label("Share", systemImage: "square.and.arrow.up")
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
            
            .sheet(isPresented: $showWriteJournalView) {
                AddNoteView { journal in
                    context.insert(journal)
                    recentJournals.insert(journal, at: 0)
                }
            }
            .sheet(isPresented: $showEditJournalView) {
                AddNoteView(journal: journalInEdit!) { updatedJournal in
                    deleteJournal(journal: journalInEdit!)
                    context.insert(updatedJournal)
                    recentJournals.insert(updatedJournal, at: 0)
                }
            }
            .onChange(of: journalInEdit) {
                newValue in
                if newValue != nil {
                    showEditJournalView = true
                }
            }
            .navigationTitle("Journella")
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
            }
            
        }
    }
    
    mutating func setJournalToEdit(journal: Journal) {
        journalInEdit = journal
    }
    
    func deleteJournal(journal: Journal) {
        withAnimation {
            context.delete(journal)
            recentJournals.removeAll { j in
                j.id == journal.id
            }
        }
    }
}
    


#Preview {
    JournalListView()
}
