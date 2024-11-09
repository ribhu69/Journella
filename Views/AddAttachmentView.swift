//
//  AddAttachmentView.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 03/11/24.
//
import SwiftUI
import SwiftData
import PhotosUI

struct AddAttachmentView: View {
    @State var journalId: String?
    @State private var isFirstLoad = true  // Make isFirstLoad a @State property
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @State var attachments: [Attachment] = []
    @State var selectedAttachments: [Attachment] = []
    
    var onsave: (([Attachment]) -> Void)?
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showFilePicker = false
    @State var showPhotoPicker = false
    @State var showCamera = false
    
    init(journalId: String?, onSave: (([Attachment]) -> Void)?) {
        _journalId = State(wrappedValue: journalId)
        self.onsave = onSave
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            Image(systemName: "paperclip.slash")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 28, height: 28)
                .foregroundColor(.gray)
            
            Text("Oops! Nothing to see here 📎")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.top, 4)
            
            Text("No attachments yet – looks like you've kept it light!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if attachments.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(attachments) { attachment in
                            AttachmentCell(attachment: attachment)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        removeAttachment(attachment: attachment)
                                    }
                                    label: {
                                        Image(systemName: "trash")
                                    }
                                }
                        }
                    }
                }
            }
            .onAppear {
                if isFirstLoad {
                    isFirstLoad = false
                    fetchAttachments()
                }
            }
            .navigationTitle("Add Attachments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Menu {
                            Button(action: {
                                showPhotoPicker.toggle()
                            }) {
                                Label("Photos", systemImage: "photo")
                            }
                            Button(action: {
                                showCamera.toggle()
                            }) {
                                Label("Camera", systemImage: "camera")
                            }
                            Button(action: {
                                showFilePicker.toggle()
                            }) {
                                Label("Files", systemImage: "doc")
                            }
                        } label: {
                            Image(systemName: "plus")
                        }
                        Button("Save") {
                            saveAttachments()
                        }
                    }
                }
            }
        }
        .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.mp3, .heic, .movie, .pdf, .jpeg], onCompletion: { result in
            showFilePicker.toggle()
            switch result {
            case .success(let success):
                handleFile(at: success)
            case .failure(let failure):
                print(failure)
            }
        })
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotoItem, matching: .any(of: [.images, .videos]), photoLibrary: .shared())
        .onChange(of: selectedPhotoItem) {
            showPhotoPicker.toggle()
            Task {
                if let localId = selectedPhotoItem?.itemIdentifier {
                    let result = PHAsset.fetchAssets(withLocalIdentifiers: [localId], options: nil)
                    if let asset = result.firstObject,
                       let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self) {
                        
                        let fileName = asset.value(forKey: "filename") as? String ?? "Unknown"
                        let creationDate = asset.creationDate ?? Date()
                        let fileSize = data.count
                        
                        let metaData = [
                            "fileName": fileName,
                            "fileSize": fileSize,
                            "creationDate": creationDate
                        ]
                        switch asset.mediaType {
                        case .image:
                            addFile(filetype: .heic, data: data, metaData: metaData)
                        case .video:
                            addFile(filetype: .mov, data: data, metaData: metaData)
                        default:
                            fatalError("Unsupported type")
                        }
                        selectedPhotoItem = nil
                    }
                }
            }
        }
    }
    
    func fetchAttachments() {
        guard let journalId else {
            print("ZXCV Journal ID is empty")
            return
        }
        let predicate = #Predicate<AttachmentMapping>{ $0.journalId == journalId }
        let attachmentMappingFD = FetchDescriptor(predicate : predicate)
        
        do {
            let attachmentMapping = try context.fetch(attachmentMappingFD)
            let attachmentIds = attachmentMapping.map { $0.attachmentId }
            
            
            let attachmentPredicate = #Predicate<Attachment>{ attachmentIds.contains($0.attachmentId) }
            let attachmentgFD = FetchDescriptor(predicate : attachmentPredicate)
            
            let attachments = try context.fetch(attachmentgFD)
            self.attachments = attachments
            selectedAttachments = self.attachments
        }
        catch {
            print(error)
        }
    }
    
    func removeAttachment(attachment: Attachment) {
        if let index = selectedAttachments.firstIndex(where: { $0.attachmentId == attachment.attachmentId }) {
            selectedAttachments.remove(at: index)
        }
        if let index = attachments.firstIndex(where: { $0.attachmentId == attachment.attachmentId }) {
            attachments.remove(at: index)
        }
    }
    
    func insertAttachment(
        attachmentData: Data,
        attachmentType: AttachmentType,
        metadata: [String: Any]
    ) {
        guard let attachmentTitle = metadata["fileName"] as? String,
              let createdDate = metadata["creationDate"] as? Date else {
            return
        }
        let attachmentSize = (metadata["fileSize"] as? Int64 ?? 0) / (1024 * 1024)
        
        let attachment = Attachment(
            attachmentId: UUID().uuidString,
            parentType: attachmentType.rawValue,
            attachmentData: attachmentData,
            attachmentTitle: attachmentTitle,
            attachmentType: attachmentType,
            attachmentSize: Double(attachmentSize),
            createdAt: createdDate
        )
        
        DispatchQueue.main.async {
            selectedAttachments.append(attachment)
            attachments.append(attachment)
        }
    }
    
    func addFile(filetype: AttachmentType, data: Data, metaData: [String: Any]) {
        insertAttachment(attachmentData: data, attachmentType: filetype, metadata: metaData)
    }
    
    func saveAttachments() {
        onsave?(selectedAttachments)
        dismiss()
    }
    
    func handleFile(at url: URL) {
        do {
            let accessing = url.startAccessingSecurityScopedResource()
            let data = try Data(contentsOf: url)
            let attachmentType = AttachmentType(stringValue: url.pathExtension.lowercased())
            
            let fileName = url.lastPathComponent
            let fileSize = try FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64 ?? 0
            let creationDate = try FileManager.default.attributesOfItem(atPath: url.path)[.creationDate] as? Date ?? Date()
            
            let metaData: [String: Any] = [
                "fileName": fileName,
                "fileSize": fileSize,
                "creationDate": creationDate
            ]
            
            insertAttachment(attachmentData: data, attachmentType: attachmentType, metadata: metaData)
            
            
            if accessing {
                url.stopAccessingSecurityScopedResource()
            }
        } catch {
            print("Error handling file: \(error)")
        }
    }
}


struct AttachmentCell : View {
    var attachment: Attachment
    var attachmentType: AttachmentType {
        return AttachmentType(rawValue: attachment.attachmentType)!
    }
    var body: some View {
        HStack {
            switch attachmentType {
            case .jpeg, .heic, .jpg, .png:
               
                
                Image("imageIcon", bundle: nil)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                
                
            case .mp4, .mov:
                
                Image("videoIcon", bundle: nil)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                
            case .mp3:
                Image("audioIcon", bundle: nil)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                
            case .pdf:
                Image("pdfIcon", bundle: nil)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            VStack(alignment: .leading) {
                Text(attachment.attachmentTitle)
                    .font(.body)
                    .foregroundStyle(.primary)
                Text(String(format: "%.2f MB", attachment.attachmentSize))
                    .font(.body)
                    .foregroundStyle(.secondary)
                
            }
            .padding(.horizontal, 8)
            
        }
        .padding(.vertical, 8)
    }
}
