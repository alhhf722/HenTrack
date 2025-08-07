import SwiftUI

struct AddHenView: View {
    @ObservedObject var viewModel: HenListViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var name = ""
    @State private var breed = ""
    @State private var birthDate = Date()
    @State private var gender = ChickenGender.hen
    @State private var featherColor = ""
    @State private var weight = ""
    @State private var breedingStatus = BreedingStatus.active
    @State private var eggLayingCapacity = EggLayingCapacity.unknown
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Name", text: $name)
                    
                    TextField("Breed", text: $breed)
                    
                    DatePicker("Birth date", selection: $birthDate, displayedComponents: .date)
                    
                    Picker("Gender", selection: $gender) {
                        ForEach(ChickenGender.allCases) { gender in
                            HStack {
                                Text(gender.icon)
                                Text(gender.rawValue)
                            }
                            .tag(gender)
                        }
                    }
                }
                
                Section(header: Text("Physical Characteristics")) {
                    TextField("Feather Color", text: $featherColor)
                    
                    TextField("Weight (grams)", text: $weight)
                        .keyboardType(.numberPad)
                    
                    Picker("Egg Laying Capacity", selection: $eggLayingCapacity) {
                        ForEach(EggLayingCapacity.allCases) { capacity in
                            Text(capacity.rawValue).tag(capacity)
                        }
                    }
                }
                
                Section(header: Text("Breeding Status")) {
                    Picker("Status", selection: $breedingStatus) {
                        ForEach(BreedingStatus.allCases) { status in
                            HStack {
                                Circle()
                                    .fill(status.color)
                                    .frame(width: 12, height: 12)
                                Text(status.rawValue)
                            }
                            .tag(status)
                        }
                    }
                }
                
                Section(header: Text("Photo (optional)")) {
                    VStack(spacing: 12) {
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 200, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
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
            }
            .navigationTitle("Add Chicken")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveHen()
                }
                .disabled(name.isEmpty || breed.isEmpty)
            )
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
    
    private func saveHen() {
        var localPhotoPath: String? = nil
        
        if let selectedImage = selectedImage {
            let filename = "hen_\(UUID().uuidString).jpg"
            localPhotoPath = selectedImage.saveToDocuments(filename: filename)
        }
        
        let hen = Hen(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            breed: breed.trimmingCharacters(in: .whitespacesAndNewlines),
            birthDate: birthDate,
            gender: gender,
            featherColor: featherColor.trimmingCharacters(in: .whitespacesAndNewlines),
            weight: Double(weight),
            breedingStatus: breedingStatus,
            parentHenId: nil,
            parentRoosterId: nil,
            generation: 1,
            eggLayingCapacity: eggLayingCapacity,
            photoURL: nil,
            localPhotoPath: localPhotoPath
        )
        
        viewModel.addHen(hen)
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddHenView_Previews: PreviewProvider {
    static var previews: some View {
        AddHenView(viewModel: HenListViewModel())
    }
} 
