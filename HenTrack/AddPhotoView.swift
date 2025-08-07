import SwiftUI

struct AddPhotoView: View {
    @ObservedObject var viewModel: HenListViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    let henId: UUID?
    
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var caption = ""
    @State private var selectedHenId: UUID?
    @State private var tags: [String] = []
    @State private var newTag = ""
    
    init(viewModel: HenListViewModel, henId: UUID? = nil) {
        self.viewModel = viewModel
        self.henId = henId
        self._selectedHenId = State(initialValue: henId)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Photo")) {
                    VStack(spacing: 12) {
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxHeight: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    Button(action: {
                                        self.selectedImage = nil
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(Circle())
                                    }
                                    .padding(8),
                                    alignment: .topTrailing
                                )
                        }
                        
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                Text("Choose photo from gallery")
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
                
                Section(header: Text("Description")) {
                    TextField("Photo caption", text: $caption)
                }
                
                Section(header: Text("Hen")) {
                    Picker("Select hen", selection: $selectedHenId) {
                        Text("Select hen").tag(nil as UUID?)
                        ForEach(viewModel.hens) { hen in
                            HStack {
                                Circle()
                                    .fill(hen.breedingStatus.color)
                                    .frame(width: 16, height: 16)
                                Text(hen.name)
                            }
                            .tag(hen.id as UUID?)
                        }
                    }
                }
                
                Section(header: Text("Tags")) {
                    HStack {
                        TextField("Add tag", text: $newTag)
                        
                        Button("Add") {
                            addTag()
                        }
                        .disabled(newTag.isEmpty)
                    }
                    
                    if !tags.isEmpty {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                            ForEach(tags, id: \.self) { tag in
                                HStack {
                                    Text("#\(tag)")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(8)
                                    
                                    Button(action: { removeTag(tag) }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Photo")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    savePhoto()
                }
                .disabled(selectedImage == nil || selectedHenId == nil)
            )
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
    
    
    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) {
            tags.append(trimmedTag)
            newTag = ""
        }
    }
    
    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
    
    private func savePhoto() {
        guard let henId = selectedHenId else { return }
        
        var localPhotoPath: String? = nil
        
        if let selectedImage = selectedImage {
            let filename = "photo_\(UUID().uuidString).jpg"
            localPhotoPath = selectedImage.saveToDocuments(filename: filename)
        }
        
        let photo = Photo(
            imageURL: nil,
            localPhotoPath: localPhotoPath,
            date: Date(),
            henId: henId,
            caption: caption.isEmpty ? nil : caption.trimmingCharacters(in: .whitespacesAndNewlines),
            tags: tags
        )
        
        viewModel.addPhoto(photo)
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        AddPhotoView(viewModel: HenListViewModel())
    }
} 
