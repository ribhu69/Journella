//
//  TagListView.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 03/11/24.
//

import SwiftUI
import SwiftData
struct TagListView : View {
    @EnvironmentObject var appDefaults: AppDefaults
    @Environment(\.modelContext) var context
    @Query private var storedTags : [Tags]
    @State private var allTags : [Tags] = []
    @State private var filteredTags : [Tags] = []
    @State var searchText = ""
    @State var showDeleteErrorAlert = false
    
    
    var body: some View {
        VStack {
            if !searchText.isEmpty && filteredTags.isEmpty {
                
                Spacer()
                Image("empty", bundle: nil)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 28, height: 28)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 4)
                Text("Tag Not Found")
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 8)
                Button {
                    addTag()
                } label: {
                    HStack {
                        Text("Add \"\(searchText)\"")
                            .font(.title3)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(RoundedRectangle(cornerRadius: 10).opacity(0.3))
                .tint(.primary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                
                Spacer()
                
            }
            else {
                List {
                    if searchText.isEmpty {
                        ForEach(allTags) { tag in
                            TagListCell(tag: tag) { tag in
                                deleteTag(tag: tag)
                            }
                        }
                    }
                    else {
                        ForEach(filteredTags) { tag in
                            TagListCell(tag: tag) { tag in
                                deleteTag(tag: tag)
                            }
                        }
                    }
                }
                .listRowSeparator(.hidden)
                .onChange(of: searchText, { oldValue, newValue in
                    filterResults()
                })
                
                .onAppear {
                    allTags = storedTags
                }
                
            }
        }
        .alert("Tag Deletion Failed", isPresented: $showDeleteErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("This tag is currently associated with existing journals. Please remove the tag from those journals before deleting.")
        }
        .navigationTitle("Tags")
        .searchable(text: $searchText, prompt: "Search Tags")
    }
    
    func addTag() {
        
        let tag = Tags(title: searchText, id: UUID().uuidString)
        context.insert(tag)
        do {
            try context.save()
            allTags.append(tag)
            searchText = ""
        }
        catch {
            fatalError()
        }
    }
    
    func deleteTag(tag: Tags) {
        
        let tagId = tag.id
        let mappingPredicate = #Predicate<TagMapping> { $0.tagId == tagId }
        let fetchDescriptor = FetchDescriptor(predicate: mappingPredicate)
        do {
            let tags = try context.fetch(fetchDescriptor)
            if tags.isEmpty {
                executeTagDeletion(tag: tag)
            }
            else {
                showDeleteErrorAlert.toggle()
            }
        }
        catch {
            print(error)
        }
        
    }
       
            
            
         
      
    private func executeTagDeletion(tag: Tags) {
        do {
            context.delete(tag)
            searchText = ""
            try context.save()
            if let firstIndex = allTags.firstIndex(where: { $0.id == tag.id }) {
                allTags.remove(at: firstIndex)
            }
            filteredTags.removeAll()
        }
        catch {
            print(error)
        }
    }
        
    func filterResults() {
        
        if !searchText.isEmpty {
            filteredTags = allTags.filter { $0.title.contains(searchText)}
        } else {
            filteredTags.removeAll()
        }
    }
}
