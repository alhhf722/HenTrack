import SwiftUI

struct HensListView: View {
    @ObservedObject var viewModel: HenListViewModel
    @State private var showingAddHen = false
    @State private var searchText = ""
    @State private var selectedGenderFilter: ChickenGender?
    
    var filteredHens: [Hen] {
        var filtered = viewModel.hens
        
        if let genderFilter = selectedGenderFilter {
            filtered = filtered.filter { $0.gender == genderFilter }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { hen in
                hen.name.localizedCaseInsensitiveContains(searchText) ||
                hen.breed.localizedCaseInsensitiveContains(searchText) ||
                hen.featherColor.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText, placeholder: "Search by name, breed, or color")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterChip(
                        title: "All",
                        isSelected: selectedGenderFilter == nil,
                        action: { selectedGenderFilter = nil }
                    )
                    
                    ForEach(ChickenGender.allCases) { gender in
                        FilterChip(
                            title: gender.rawValue,
                            isSelected: selectedGenderFilter == gender,
                            action: { selectedGenderFilter = gender }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            
            if filteredHens.isEmpty {
                EmptyStateView(viewModel: viewModel)
            } else {
                List {
                    ForEach(filteredHens) { hen in
                        NavigationLink(destination: HenDetailView(hen: hen, viewModel: viewModel)) {
                            HenCardView(hen: hen, viewModel: viewModel)
                        }
                    }
                    .onDelete(perform: deleteHens)
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Breeding Stock")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarItems(trailing: Button(action: { showingAddHen = true }) {
            Image(systemName: "plus")
        })
        .sheet(isPresented: $showingAddHen) {
            AddHenView(viewModel: viewModel)
        }
    }
    
    private func deleteHens(offsets: IndexSet) {
        let hensToDelete = offsets.map { filteredHens[$0] }
        for hen in hensToDelete {
            viewModel.deleteHen(hen)
        }
    }
}

struct HenCardView: View {
    let hen: Hen
    @ObservedObject var viewModel: HenListViewModel
    
    var henNotes: [Note] {
        viewModel.getNotes(for: hen.id)
    }
    
    var henPhotos: [Photo] {
        viewModel.getPhotos(for: hen.id)
    }
    
    var henBreedings: [BreedingRecord] {
        viewModel.getBreedingRecords(for: hen.id)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Group {
                if let localPhotoPath = hen.localPhotoPath,
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
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(hen.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(hen.gender.icon)
                        .font(.title3)
                    
                    Spacer()
                    
                    Text(hen.breedingStatus.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(hen.breedingStatus.color.opacity(0.2))
                        .foregroundColor(hen.breedingStatus.color)
                        .cornerRadius(8)
                }
                
                Text(hen.breed)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(hen.featherColor)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    Label("\(hen.age) years", systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if hen.canBreed {
                        Label("Breeder", systemImage: "heart.fill")
                            .font(.caption)
                            .foregroundColor(.pink)
                    }
                    
                    Label("\(henNotes.count) notes", systemImage: "note.text")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if !henBreedings.isEmpty {
                        Label("\(henBreedings.count) breedings", systemImage: "heart")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct EmptyStateView: View {
    @ObservedObject var viewModel: HenListViewModel
    @State private var showingAddHen = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "plus.circle")
                .font(.system(size: 80))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Breeding Stock")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Add your first chicken to start breeding program")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                showingAddHen = true
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Chicken")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showingAddHen) {
            AddHenView(viewModel: viewModel)
        }
    }
}

struct HensListView_Previews: PreviewProvider {
    static var previews: some View {
        HensListView(viewModel: HenListViewModel())
    }
} 
