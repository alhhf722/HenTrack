import SwiftUI

struct PhotoAlbumView: View {
    @ObservedObject var viewModel: HenListViewModel
    @State private var showingAddPhoto = false
    @State private var showingFilters = false
    @State private var selectedPhoto: Photo?
    @State private var showingFullScreen = false
    
    var body: some View {
        VStack {
            PhotoFiltersView(viewModel: viewModel)
            
                                if viewModel.filteredPhotos.isEmpty {
                    EmptyPhotosView()
                } else {
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                            ForEach(viewModel.filteredPhotos) { photo in
                                PhotoGridView(photo: photo) {
                                    deletePhoto(photo)
                                }
                            }
                        }
                        .padding()
                    }
                }
        }
                    .navigationTitle("Photo Album")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarItems(
                            leading: Button("Filters") {
                    showingFilters = true
                },
            trailing: Button(action: { showingAddPhoto = true }) {
                Image(systemName: "plus")
            }
        )
        .sheet(isPresented: $showingAddPhoto) {
            AddPhotoView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingFilters) {
            PhotoFiltersSheetView(viewModel: viewModel)
        }
        .fullScreenCover(isPresented: $showingFullScreen) {
            if let photo = selectedPhoto {
                FullScreenPhotoView(photo: photo, viewModel: viewModel)
            }
        }
    }
    
    private func deletePhoto(_ photo: Photo) {
        if let localPhotoPath = photo.localPhotoPath {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent(localPhotoPath)
            
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("File deleted: \(fileURL.path)")
            } catch {
                print("Error deleting file: \(error)")
            }
        }
        
        viewModel.deletePhoto(photo)
    }
}

struct PhotoFiltersView: View {
    @ObservedObject var viewModel: HenListViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    title: viewModel.selectedPhotoDateFilter.rawValue,
                    isSelected: viewModel.selectedPhotoDateFilter != .all,
                    action: {
                        
                    }
                )
                
                if let henId = viewModel.selectedPhotoHenFilter,
                   let hen = viewModel.getHen(by: henId) {
                    FilterChip(
                        title: hen.name,
                        isSelected: true,
                        action: {
                            viewModel.selectedPhotoHenFilter = nil
                        }
                    )
                }
                
                if let tag = viewModel.selectedPhotoTagFilter {
                    FilterChip(
                        title: "#\(tag)",
                        isSelected: true,
                        action: {
                            viewModel.selectedPhotoTagFilter = nil
                        }
                    )
                }
                
                if viewModel.selectedPhotoDateFilter != .all ||
                   viewModel.selectedPhotoHenFilter != nil ||
                   viewModel.selectedPhotoTagFilter != nil {
                    FilterChip(
                        title: "Clear",
                        isSelected: false,
                        action: {
                            viewModel.selectedPhotoDateFilter = .all
                            viewModel.selectedPhotoHenFilter = nil
                            viewModel.selectedPhotoTagFilter = nil
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}

struct PhotoGridView: View {
    let photo: Photo
    let onDelete: () -> Void
    
    var body: some View {
        Group {
            if let localPhotoPath = photo.localPhotoPath {
                if let image = localPhotoPath.loadImageFromDocuments() {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(systemName: "photo")
                        .foregroundColor(.secondary)
                }
            } else {
                Image(systemName: "photo")
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray5))
        .frame(width: 100, height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .onLongPressGesture {
            onDelete()
        }
        .overlay(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: "trash.circle.fill")
                        .foregroundColor(.red)
                        .background(Color.white)
                        .clipShape(Circle())
                        .padding(4)
                }
            }
        )
    }
}

struct FullScreenPhotoView: View {
    let photo: Photo
    let viewModel: HenListViewModel
    @Environment(\.presentationMode) private var presentationMode
    @State private var showingHenDetail = false
    
    var hen: Hen? {
        viewModel.getHen(by: photo.henId)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Group {
                    if let localPhotoPath = photo.localPhotoPath,
                       let image = localPhotoPath.loadImageFromDocuments() {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        Image(systemName: "photo")
                            .font(.system(size: 100))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    if let caption = photo.caption {
                        Text(caption)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    
                    HStack {
                        if let hen = hen {
                            Button(action: { showingHenDetail = true }) {
                                HStack {
                                    Circle()
                                        .fill(hen.breedingStatus.color)
                                        .frame(width: 16, height: 16)
                                    
                                    Text(hen.name)
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Text(photo.formattedDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if !photo.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(photo.tags, id: \.self) { tag in
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
                .background(Color(.systemBackground))
            }
            .navigationTitle("Photo")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Share") {
                    
                }
            )
            .sheet(isPresented: $showingHenDetail) {
                if let hen = hen {
                    NavigationView {
                        HenDetailView(hen: hen, viewModel: viewModel)
                    }
                }
            }
        }
    }
}

struct EmptyPhotosView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 80))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Photos")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Add your first photo to start the album")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

struct PhotoFiltersSheetView: View {
    @ObservedObject var viewModel: HenListViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Date Filter")) {
                    Picker("Period", selection: $viewModel.selectedPhotoDateFilter) {
                        ForEach(DateFilter.allCases) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Hen Filter")) {
                    Picker("Hen", selection: $viewModel.selectedPhotoHenFilter) {
                        Text("All hens").tag(nil as UUID?)
                        ForEach(viewModel.hens) { hen in
                            Text(hen.name).tag(hen.id as UUID?)
                        }
                    }
                }
                
                Section(header: Text("Tag Filter")) {
                    Picker("Tag", selection: $viewModel.selectedPhotoTagFilter) {
                        Text("All tags").tag(nil as String?)
                        ForEach(viewModel.allTags, id: \.self) { tag in
                            Text("#\(tag)").tag(tag as String?)
                        }
                    }
                }
                
                Section {
                    Button("Clear All Filters") {
                        viewModel.selectedPhotoDateFilter = .all
                        viewModel.selectedPhotoHenFilter = nil
                        viewModel.selectedPhotoTagFilter = nil
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Photo Filters")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct PhotoAlbumView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoAlbumView(viewModel: HenListViewModel())
    }
}
