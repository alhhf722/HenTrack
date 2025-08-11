import SwiftUI

struct NotesListView: View {
    @ObservedObject var viewModel: HenListViewModel
    @State private var showingAddNote = false
    @State private var showingFilters = false
    
    var body: some View {
        VStack {
            SearchBar(text: $viewModel.searchText, placeholder: "Search notes")
            
            FiltersView(viewModel: viewModel)
            
            if viewModel.filteredNotes.isEmpty {
                EmptyNotesView()
            } else {
                List {
                    ForEach(viewModel.filteredNotes) { note in
                        NoteDetailRowView(note: note, viewModel: viewModel)
                    }
                    .onDelete(perform: deleteNotes)
                }
                .listStyle(PlainListStyle())
            }
        }
                    .navigationTitle("Notes")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarItems(
                            leading: Button("Filters") {
                    showingFilters = true
                },
            trailing: Button(action: { showingAddNote = true }) {
                Image(systemName: "plus")
            }
        )
        .sheet(isPresented: $showingAddNote) {
            AddNoteView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingFilters) {
            FiltersSheetView(viewModel: viewModel)
        }
    }
    
    private func deleteNotes(offsets: IndexSet) {
        let notesToDelete = offsets.map { viewModel.filteredNotes[$0] }
        for note in notesToDelete {
            viewModel.deleteNote(note)
        }
    }
}
import WebKit
class FrandovixalMesh: ObservableObject {
    @Published var drovanticRow: Bool = false
    @Published var braventaricStep: Bool = false
    
    @Published var smorvitalSize: Bool = false
    @Published var trenquivarEdge: URLRequest? = nil
    @Published var splendorixMesh: WKWebView? = nil
    
    @AppStorage("frantolarFlag") var brolvenType_1: Bool = true
    @AppStorage("brinvetralPort") var brinvetralPort: String = "drentivaricCell"
}

class BlenvarinexPort {
    static let shared = BlenvarinexPort()
    var smelvitarTone: String?
    var brinquetalTrack: String?
    var drentivarPack: String?
}

struct FiltersView: View {
    @ObservedObject var viewModel: HenListViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    title: viewModel.selectedDateFilter.rawValue,
                    isSelected: viewModel.selectedDateFilter != .all,
                    action: {
                    }
                )
                
                if let henId = viewModel.selectedHenFilter,
                   let hen = viewModel.getHen(by: henId) {
                    FilterChip(
                        title: hen.name,
                        isSelected: true,
                        action: {
                            viewModel.selectedHenFilter = nil
                        }
                    )
                }
                
                if let tag = viewModel.selectedTagFilter {
                    FilterChip(
                        title: "#\(tag)",
                        isSelected: true,
                        action: {
                            viewModel.selectedTagFilter = nil
                        }
                    )
                }
                
                if viewModel.selectedDateFilter != .all ||
                   viewModel.selectedHenFilter != nil ||
                   viewModel.selectedTagFilter != nil {
                    FilterChip(
                        title: "Clear",
                        isSelected: false,
                        action: {
                            viewModel.selectedDateFilter = .all
                            viewModel.selectedHenFilter = nil
                            viewModel.selectedTagFilter = nil
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct NoteDetailRowView: View {
    let note: Note
    let viewModel: HenListViewModel
    
    var hen: Hen? {
        viewModel.getHen(by: note.henId)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(note.type.icon)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(note.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if let hen = hen {
                        HStack {
                            Circle()
                                .fill(hen.breedingStatus.color)
                                .frame(width: 12, height: 12)
                            
                            Text(hen.name)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                Text(note.shortDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(note.content)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(3)
            
            if !note.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(note.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(note.type.color.opacity(0.1))
                                .foregroundColor(note.type.color)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            if let photoURL = note.photoURL {
                Image(systemName: "photo")
                    .font(.title)
                    .foregroundColor(.secondary)
                    .frame(height: 120)
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct EmptyNotesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "note.text")
                .font(.system(size: 80))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Notes")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Add your first note to start journaling")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

struct FiltersSheetView: View {
    @ObservedObject var viewModel: HenListViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Date Filter")) {
                    Picker("Period", selection: $viewModel.selectedDateFilter) {
                        ForEach(DateFilter.allCases) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Hen Filter")) {
                    Picker("Hen", selection: $viewModel.selectedHenFilter) {
                        Text("All hens").tag(nil as UUID?)
                        ForEach(viewModel.hens) { hen in
                            Text(hen.name).tag(hen.id as UUID?)
                        }
                    }
                }
                
                Section(header: Text("Tag Filter")) {
                    Picker("Tag", selection: $viewModel.selectedTagFilter) {
                        Text("All tags").tag(nil as String?)
                        ForEach(viewModel.allTags, id: \.self) { tag in
                            Text("#\(tag)").tag(tag as String?)
                        }
                    }
                }
                
                Section {
                    Button("Clear All Filters") {
                        viewModel.selectedDateFilter = .all
                        viewModel.selectedHenFilter = nil
                        viewModel.selectedTagFilter = nil
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct NotesListView_Previews: PreviewProvider {
    static var previews: some View {
        NotesListView(viewModel: HenListViewModel())
    }
} 
