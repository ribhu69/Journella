//
//  AddTagView.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 19/10/24.
//
import SwiftUI
import SwiftData

struct AddTagView : View {
    
    var existingTags : [Tags]?
    var completion : ([Tags])->Void
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @Query private var allTags : [Tags]
    @State var storedTags = [Tags]()
    @State var showAddTagView = false
    @State private var searchText = ""
    @State var filteredResults = [Tags]()
    @State var selectedTags = [Tags]()
    
    var body: some View {
        NavigationView {
            
            VStack {
                
                if !searchText.isEmpty && filteredResults.isEmpty {
                  
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
                    ScrollView {
                        
                        if !searchText.isEmpty {
                            ForEach(filteredResults) { tag in
                                TagCell(tag: tag) { tag in
                                    selectedTags.append(tag)
                                }
                            }
                        }
                        else {
                            VStack(alignment : .leading) {
                                
                                if !selectedTags.isEmpty {
                                    
                                    VStack(alignment: .leading) {
                                        Text("Selected Tags")
                                            .foregroundStyle(.secondary)
                                        ScrollView(.horizontal) {
                                            LazyHStack {
                                                ForEach(selectedTags) {tag in
                                                    SelectedTagCell(tag: tag) { tag in
                                                        removeTag(tag: tag)
                                                    }
                                                    
                                                }
                                            }
                                        }
                                        .scrollIndicators(.hidden)
                                        Rectangle()
                                            .frame(height: 0.5)
                                            .foregroundStyle(.secondary)
                                            .padding(.bottom, 8)
                                    }
                                    
                                }

                                if !storedTags.isEmpty {
                                    Text("All Tags")
                                        .foregroundStyle(.secondary)
                                    ForEach(storedTags) { tag in
                                        TagCell(tag: tag) { tag in
                                            insertTag(tag: tag)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                }
                
            }
           
            
            .onChange(of: searchText, { oldValue, newValue in
                filterResults()
            })
            .onAppear {
                if let existingTags {
                    segregateTags(selectedTags: existingTags)
                }
                else {
                    storedTags = allTags
                }
            }
            .navigationTitle("Add Tags")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search Tags")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        saveTags()
                    }, label: {
                        Text("Save")
                    })
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        cancelView()
                    }, label: {
                        Text("Cancel")
                    })
                }
            }
        }
    }
    
    func saveTags() {
        completion(selectedTags)
        dismiss()
    }
    
    func cancelView() {
        dismiss()
    }
    
    func segregateTags(selectedTags : [Tags]) {
        
        self.selectedTags = allTags.filter { selectedTags.contains($0) }
        self.storedTags = allTags.filter { !selectedTags.contains($0) }
    }
    
    func addTag() {
        
        let tag = Tags(title: searchText, id: UUID().uuidString)
        context.insert(tag)
        do {
            try context.save()
            selectedTags.append(tag)
            searchText = ""
        }
        catch {
            fatalError()
        }
        
        
    }
    
    func insertTag(tag: Tags) {
        selectedTags.append(tag)
        if let firstIndex = storedTags.firstIndex(where: { item in
            item.id == tag.id
        }) {
            storedTags.remove(at: firstIndex)
        }
    }
    
    func removeTag(tag: Tags) {
        if let firstIndex = selectedTags.firstIndex(where: { iteratingTag in
            iteratingTag.id == tag.id
        }) {
            selectedTags.remove(at: firstIndex)
        }
        storedTags.append(tag)
    }
    
    func filterResults() {
        
        if !searchText.isEmpty {
            filteredResults = storedTags.filter { $0.title.contains(searchText)}
        } else {
            filteredResults.removeAll()
        }
    }
}

#Preview {

    AddTagView(existingTags: nil, completion: { newtags in
        //
    })
        .environmentObject(AppDefaults.shared)
}
