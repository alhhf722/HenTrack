import SwiftUI

struct EditHenView: View {
    let hen: Hen
    @ObservedObject var viewModel: HenListViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var name: String
    @State private var breed: String
    @State private var birthDate: Date
    @State private var gender: ChickenGender
    @State private var featherColor: String
    @State private var weight: String
    @State private var breedingStatus: BreedingStatus
    @State private var eggLayingCapacity: EggLayingCapacity
    @State private var photoURL: String
    
    init(hen: Hen, viewModel: HenListViewModel) {
        self.hen = hen
        self.viewModel = viewModel
        self._name = State(initialValue: hen.name)
        self._breed = State(initialValue: hen.breed)
        self._birthDate = State(initialValue: hen.birthDate)
        self._gender = State(initialValue: hen.gender)
        self._featherColor = State(initialValue: hen.featherColor)
        self._weight = State(initialValue: hen.weight?.description ?? "")
        self._breedingStatus = State(initialValue: hen.breedingStatus)
        self._eggLayingCapacity = State(initialValue: hen.eggLayingCapacity)
        self._photoURL = State(initialValue: hen.photoURL ?? "")
    }
    
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
                
                Section(header: Text("Photo")) {
                    TextField("Photo URL", text: $photoURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                    
                    if !photoURL.isEmpty {
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                            .frame(maxHeight: 200)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                    }
                }
                
                Section {
                    Button("Delete Chicken") {
                        viewModel.deleteHen(hen)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Edit Chicken")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveChanges()
                }
                .disabled(name.isEmpty || breed.isEmpty)
            )
        }
    }
    
    private func saveChanges() {
        var updatedHen = hen
        updatedHen.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedHen.breed = breed.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedHen.birthDate = birthDate
        updatedHen.gender = gender
        updatedHen.featherColor = featherColor.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedHen.weight = Double(weight)
        updatedHen.breedingStatus = breedingStatus
        updatedHen.eggLayingCapacity = eggLayingCapacity
        updatedHen.photoURL = photoURL.isEmpty ? nil : photoURL
        
        viewModel.updateHen(updatedHen)
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditHenView_Previews: PreviewProvider {
    static var previews: some View {
        EditHenView(
            hen: Hen(
                name: "Redhead",
                breed: "Russian White",
                birthDate: Date(),
                gender: .hen,
                featherColor: "Red",
                weight: 2000,
                breedingStatus: .active,
                parentHenId: nil,
                parentRoosterId: nil,
                generation: 1,
                eggLayingCapacity: .good
            ),
            viewModel: HenListViewModel()
        )
    }
} 
