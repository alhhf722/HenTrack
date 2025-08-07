import SwiftUI

struct HenDetailView: View {
    let hen: Hen
    @ObservedObject var viewModel: HenListViewModel
    @State private var showingAddNote = false
    @State private var showingAddPhoto = false
    @State private var showingEditHen = false
    @State private var showingExportSheet = false
    
    var henNotes: [Note] {
        viewModel.getNotes(for: hen.id)
    }
    
    var henPhotos: [Photo] {
        viewModel.getPhotos(for: hen.id)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HenProfileCard(hen: hen)
                
                QuickActionsCard(
                    hen: hen,
                    onAddNote: { showingAddNote = true },
                    onAddPhoto: { showingAddPhoto = true },
                    onExport: { showingExportSheet = true }
                )
                
                StatisticsCard(hen: hen, notes: henNotes, photos: henPhotos)
                
                RecentNotesCard(notes: henNotes, viewModel: viewModel)
                
                RecentPhotosCard(photos: henPhotos, viewModel: viewModel)
                
                Spacer(minLength: 100)
            }
            .padding()
        }
        .navigationTitle(hen.name)
        .navigationBarTitleDisplayMode(.large)
        .navigationBarItems(
            trailing: Button("Edit") {
                showingEditHen = true
            }
        )
        .sheet(isPresented: $showingAddNote) {
            AddNoteView(viewModel: viewModel, henId: hen.id)
        }
        .sheet(isPresented: $showingAddPhoto) {
            AddPhotoView(viewModel: viewModel, henId: hen.id)
        }
        .sheet(isPresented: $showingEditHen) {
            EditHenView(hen: hen, viewModel: viewModel)
        }
        .sheet(isPresented: $showingExportSheet) {
            ExportView(hen: hen, viewModel: viewModel)
        }
    }
}

struct HenProfileCard: View {
    let hen: Hen
    
    var body: some View {
        VStack(spacing: 16) {
            Group {
                if let localPhotoPath = hen.localPhotoPath,
                   let image = localPhotoPath.loadImageFromDocuments() {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(systemName: "photo")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 120, height: 120)
            .background(Color(.systemGray5))
            .clipShape(Circle())
            
            VStack(spacing: 8) {
                HStack {
                    Text(hen.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(hen.gender.icon)
                        .font(.title2)
                }
                
                Text(hen.breed)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    Label("\(hen.age) years", systemImage: "calendar")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(hen.breedingStatus.rawValue)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(hen.breedingStatus.color.opacity(0.2))
                        .foregroundColor(hen.breedingStatus.color)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct QuickActionsCard: View {
    let hen: Hen
    let onAddNote: () -> Void
    let onAddPhoto: () -> Void
    let onExport: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                QuickActionButton(
                    title: "Add Note",
                    icon: "note.text",
                    color: .blue,
                    action: onAddNote
                )
                
                QuickActionButton(
                    title: "Add Photo",
                    icon: "camera",
                    color: .green,
                    action: onAddPhoto
                )
                
                QuickActionButton(
                    title: "Export PDF",
                    icon: "square.and.arrow.up",
                    color: .orange,
                    action: onExport
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatisticsCard: View {
    let hen: Hen
    let notes: [Note]
    let photos: [Photo]
    
    var monthlyNotesCount: Int {
        let calendar = Calendar.current
        let now = Date()
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        
        return notes.filter { $0.date >= monthAgo }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                StatItem(
                    icon: "note.text",
                    title: "Total Notes",
                    value: "\(notes.count)",
                    color: .blue
                )
                
                StatItem(
                    icon: "photo",
                    title: "Total Photos",
                    value: "\(photos.count)",
                    color: .green
                )
                
                StatItem(
                    icon: "calendar",
                    title: "This Month",
                    value: "\(monthlyNotesCount)",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct StatItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct RecentNotesCard: View {
    let notes: [Note]
    let viewModel: HenListViewModel
    
    var recentNotes: [Note] {
        Array(notes.prefix(3))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Notes")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !notes.isEmpty {
                    NavigationLink("All", destination: NotesListView(viewModel: viewModel))
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            if recentNotes.isEmpty {
                Text("No Notes")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(recentNotes) { note in
                        NoteRowView(note: note, viewModel: viewModel)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct NoteRowView: View {
    let note: Note
    let viewModel: HenListViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(note.type.icon)
                    .font(.title3)
                
                Text(note.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(note.shortDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(note.content)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            if !note.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(note.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct RecentPhotosCard: View {
    let photos: [Photo]
    let viewModel: HenListViewModel
    
    var recentPhotos: [Photo] {
        Array(photos.prefix(3))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Photos")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !photos.isEmpty {
                    NavigationLink("All", destination: PhotoAlbumView(viewModel: viewModel))
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            if recentPhotos.isEmpty {
                Text("No Photos")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(recentPhotos) { photo in
                        PhotoThumbnailView(photo: photo)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct PhotoThumbnailView: View {
    let photo: Photo
    
    var body: some View {
        Group {
            if let localPhotoPath = photo.localPhotoPath,
               let image = localPhotoPath.loadImageFromDocuments() {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image(systemName: "photo")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 80, height: 80)
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
