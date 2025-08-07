import SwiftUI

struct AddNoteView: View {
    @ObservedObject var viewModel: HenListViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    let henId: UUID?
    
    @State private var title = ""
    @State private var content = ""
    @State private var selectedHenId: UUID?
    @State private var noteType = NoteType.general
    @State private var tags: [String] = []
    @State private var newTag = ""
    @State private var photoURL = ""
    
    init(viewModel: HenListViewModel, henId: UUID? = nil) {
        self.viewModel = viewModel
        self.henId = henId
        self._selectedHenId = State(initialValue: henId)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Title", text: $title)
                    
                    TextEditor(text: $content)
                        .frame(minHeight: 100)
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
                
                Section(header: Text("Note Type")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(NoteType.allCases) { type in
                                Button(action: {
                                    noteType = type
                                }) {
                                    VStack(spacing: 4) {
                                        Text(type.icon)
                                            .font(.title2)
                                        Text(type.rawValue)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(noteType == type ? .white : type.color)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(noteType == type ? type.color : type.color.opacity(0.1))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(type.color, lineWidth: noteType == type ? 0 : 1)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
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
                                        .background(noteType.color.opacity(0.1))
                                        .foregroundColor(noteType.color)
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
                
                Section(header: Text("Photo (optional)")) {
                    TextField("Photo URL", text: $photoURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("Add Note")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveNote()
                }
                .disabled(title.isEmpty || content.isEmpty || selectedHenId == nil)
            )
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
    
    private func saveNote() {
        guard let henId = selectedHenId else { return }
        
        let note = Note(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            content: content.trimmingCharacters(in: .whitespacesAndNewlines),
            date: Date(),
            henId: henId,
            tags: tags,
            photoURL: photoURL.isEmpty ? nil : photoURL,
            type: noteType
        )
        
        viewModel.addNote(note)
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddNoteView_Previews: PreviewProvider {
    static var previews: some View {
        AddNoteView(viewModel: HenListViewModel())
    }
} 