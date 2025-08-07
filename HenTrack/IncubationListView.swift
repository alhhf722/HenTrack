import SwiftUI

private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter.string(from: date)
}

struct IncubationListView: View {
    @ObservedObject var viewModel: HenListViewModel
    @State private var showingAddIncubation = false
    @State private var selectedIncubation: IncubationRecord?
    
    var body: some View {
        List {
            Section(header: Text("Active Incubations")) {
                ForEach(viewModel.getActiveIncubations()) { incubation in
                    IncubationRecordRow(incubation: incubation, viewModel: viewModel)
                        .onTapGesture {
                            selectedIncubation = incubation
                        }
                }
                .onDelete(perform: deleteIncubations)
            }
            
            Section(header: Text("All Incubations")) {
                ForEach(viewModel.incubationRecords.sorted { $0.startDate > $1.startDate }) { incubation in
                    IncubationRecordRow(incubation: incubation, viewModel: viewModel)
                        .onTapGesture {
                            selectedIncubation = incubation
                        }
                }
                .onDelete(perform: deleteIncubations)
            }
        }
        .navigationTitle("Incubation")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddIncubation = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddIncubation) {
            AddIncubationView(viewModel: viewModel)
        }
        .sheet(item: $selectedIncubation) { incubation in
            IncubationDetailView(incubation: incubation, viewModel: viewModel)
        }
    }
    
    private func deleteIncubations(offsets: IndexSet) {
        for index in offsets {
            let incubation = viewModel.incubationRecords.sorted { $0.startDate > $1.startDate }[index]
            viewModel.deleteIncubationRecord(incubation)
        }
    }
}

struct IncubationRecordRow: View {
    let incubation: IncubationRecord
    @ObservedObject var viewModel: HenListViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Breeding: \(breedingPairName)")
                        .font(.headline)
                    
                    Text("Started: \(incubation.startDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(incubation.eggsCount) eggs")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if incubation.isHatchingSoon {
                        Text("Hatching Soon!")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .fontWeight(.bold)
                    } else if incubation.isOverdue {
                        Text("Overdue")
                            .font(.caption)
                            .foregroundColor(.red)
                            .fontWeight(.bold)
                    } else {
                        Text("\(incubation.daysUntilHatch) days left")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if let temperature = incubation.temperature {
                HStack {
                    Image(systemName: "thermometer")
                        .foregroundColor(.red)
                    Text("\(temperature, specifier: "%.1f")°C")
                        .font(.caption)
                    
                    if let humidity = incubation.humidity {
                        Image(systemName: "drop.fill")
                            .foregroundColor(.blue)
                        Text("\(humidity, specifier: "%.0f")%")
                            .font(.caption)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var breedingPairName: String {
        if let breedingRecord = viewModel.breedingRecords.first(where: { $0.id == incubation.breedingRecordId }) {
            let henName = viewModel.getHen(by: breedingRecord.henId)?.name ?? "Unknown"
            let roosterName = viewModel.getHen(by: breedingRecord.roosterId)?.name ?? "Unknown"
            return "\(henName) × \(roosterName)"
        }
        return "Unknown Pair"
    }
}

struct IncubationDetailView: View {
    let incubation: IncubationRecord
    @ObservedObject var viewModel: HenListViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingEdit = false
    @State private var showingAddCandling = false
    @State private var showingAddHatching = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Incubation Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Incubation Details")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            DetailRow(title: "Breeding Pair", value: breedingPairName)
                            DetailRow(title: "Start Date", value: formatDate(incubation.startDate))
                            DetailRow(title: "Expected Hatch", value: formatDate(incubation.expectedHatchDate))
                            DetailRow(title: "Eggs Count", value: "\(incubation.eggsCount)")
                            
                            if let temperature = incubation.temperature {
                                DetailRow(title: "Temperature", value: String(format: "%.1f°C", temperature))
                            }
                            
                            if let humidity = incubation.humidity {
                                DetailRow(title: "Humidity", value: String(format: "%.0f%%", humidity))
                            }
                            
                            DetailRow(title: "Days Until Hatch", value: "\(incubation.daysUntilHatch)")
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    // Candling Results
                    if !incubation.candlingResults.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Candling Results")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button("Add Result") {
                                    showingAddCandling = true
                                }
                                .font(.caption)
                            }
                            
                            ForEach(incubation.candlingResults.sorted { $0.date > $1.date }) { result in
                                CandlingResultRow(result: result)
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Candling Results")
                                .font(.headline)
                            
                            Button("Add First Candling") {
                                showingAddCandling = true
                            }
                            .font(.caption)
                        }
                    }
                    
                    // Hatching Records
                    let hatchingRecords = viewModel.getHatchingRecords(for: incubation.id)
                    if !hatchingRecords.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Hatching Records")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button("Add Record") {
                                    showingAddHatching = true
                                }
                                .font(.caption)
                            }
                            
                            ForEach(hatchingRecords) { record in
                                HatchingRecordRow(record: record)
                            }
                        }
                    } else if incubation.isOverdue || incubation.isHatchingSoon {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Hatching Records")
                                .font(.headline)
                            
                            Button("Add Hatching Record") {
                                showingAddHatching = true
                            }
                            .font(.caption)
                        }
                    }
                    
                    // Notes
                    if let notes = incubation.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)
                            
                            Text(notes)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Incubation Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEdit = true
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditIncubationView(incubation: incubation, viewModel: viewModel)
        }
        .sheet(isPresented: $showingAddCandling) {
            AddCandlingView(incubation: incubation, viewModel: viewModel)
        }
        .sheet(isPresented: $showingAddHatching) {
            AddHatchingView(incubation: incubation, viewModel: viewModel)
        }
    }
    
    private var breedingPairName: String {
        if let breedingRecord = viewModel.breedingRecords.first(where: { $0.id == incubation.breedingRecordId }) {
            let henName = viewModel.getHen(by: breedingRecord.henId)?.name ?? "Unknown"
            let roosterName = viewModel.getHen(by: breedingRecord.roosterId)?.name ?? "Unknown"
            return "\(henName) × \(roosterName)"
        }
        return "Unknown Pair"
    }
}

struct CandlingResultRow: View {
    let result: CandlingResult
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Egg #\(result.eggNumber)")
                    .font(.subheadline)
                Text(result.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(result.isFertile ? "Fertile" : "Infertile")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(result.isFertile ? Color.green : Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                
                Text(result.developmentStage.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(8)
    }
}

struct HatchingRecordRow: View {
    let record: HatchingRecord
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Hatch Date: \(record.hatchDate, style: .date)")
                    .font(.subheadline)
                Text("Total Chicks: \(record.chicksCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(record.healthyChicks) healthy")
                    .font(.caption)
                    .foregroundColor(.green)
                
                if record.weakChicks > 0 {
                    Text("\(record.weakChicks) weak")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(8)
    }
}

struct AddIncubationView: View {
    @ObservedObject var viewModel: HenListViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedBreedingRecordId: UUID?
    @State private var startDate = Date()
    @State private var eggsCount = ""
    @State private var temperature: String = ""
    @State private var humidity: String = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Breeding Record")) {
                    Picker("Select Breeding", selection: $selectedBreedingRecordId) {
                        Text("Select Breeding").tag(nil as UUID?)
                        ForEach(viewModel.breedingRecords) { record in
                            let henName = viewModel.getHen(by: record.henId)?.name ?? "Unknown"
                            let roosterName = viewModel.getHen(by: record.roosterId)?.name ?? "Unknown"
                            Text("\(henName) × \(roosterName)").tag(record.id as UUID?)
                        }
                    }
                }
                
                Section(header: Text("Incubation Details")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    
                    TextField("Number of Eggs", text: $eggsCount)
                        .keyboardType(.numberPad)
                    
                    TextField("Temperature (°C)", text: $temperature)
                        .keyboardType(.decimalPad)
                    
                    TextField("Humidity (%)", text: $humidity)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Add Incubation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveIncubation()
                    }
                    .disabled(selectedBreedingRecordId == nil || eggsCount.isEmpty)
                }
            }
        }
    }
    
    private func saveIncubation() {
        guard let breedingRecordId = selectedBreedingRecordId,
              let eggsCountInt = Int(eggsCount) else { return }
        
        let expectedHatchDate = Calendar.current.date(byAdding: .day, value: 21, to: startDate) ?? startDate
        
        let incubation = IncubationRecord(
            breedingRecordId: breedingRecordId,
            startDate: startDate,
            expectedHatchDate: expectedHatchDate,
            temperature: Double(temperature),
            humidity: Double(humidity),
            eggsCount: eggsCountInt,
            notes: notes.isEmpty ? nil : notes
        )
        
        viewModel.addIncubationRecord(incubation)
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditIncubationView: View {
    let incubation: IncubationRecord
    @ObservedObject var viewModel: HenListViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedBreedingRecordId: UUID
    @State private var startDate: Date
    @State private var eggsCount: String
    @State private var temperature: String
    @State private var humidity: String
    @State private var notes: String
    
    init(incubation: IncubationRecord, viewModel: HenListViewModel) {
        self.incubation = incubation
        self.viewModel = viewModel
        
        _selectedBreedingRecordId = State(initialValue: incubation.breedingRecordId)
        _startDate = State(initialValue: incubation.startDate)
        _eggsCount = State(initialValue: incubation.eggsCount.description)
        _temperature = State(initialValue: incubation.temperature?.description ?? "")
        _humidity = State(initialValue: incubation.humidity?.description ?? "")
        _notes = State(initialValue: incubation.notes ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Breeding Record")) {
                    Picker("Select Breeding", selection: $selectedBreedingRecordId) {
                        ForEach(viewModel.breedingRecords) { record in
                            let henName = viewModel.getHen(by: record.henId)?.name ?? "Unknown"
                            let roosterName = viewModel.getHen(by: record.roosterId)?.name ?? "Unknown"
                            Text("\(henName) × \(roosterName)").tag(record.id)
                        }
                    }
                }
                
                Section(header: Text("Incubation Details")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    
                    TextField("Number of Eggs", text: $eggsCount)
                        .keyboardType(.numberPad)
                    
                    TextField("Temperature (°C)", text: $temperature)
                        .keyboardType(.decimalPad)
                    
                    TextField("Humidity (%)", text: $humidity)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Edit Incubation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveIncubation()
                    }
                }
            }
        }
    }
    
    private func saveIncubation() {
        guard let eggsCountInt = Int(eggsCount) else { return }
        
        let expectedHatchDate = Calendar.current.date(byAdding: .day, value: 21, to: startDate) ?? startDate
        
        var updatedIncubation = incubation
        updatedIncubation.breedingRecordId = selectedBreedingRecordId
        updatedIncubation.startDate = startDate
        updatedIncubation.expectedHatchDate = expectedHatchDate
        updatedIncubation.temperature = Double(temperature)
        updatedIncubation.humidity = Double(humidity)
        updatedIncubation.eggsCount = eggsCountInt
        updatedIncubation.notes = notes.isEmpty ? nil : notes
        
        viewModel.updateIncubationRecord(updatedIncubation)
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddCandlingView: View {
    let incubation: IncubationRecord
    @ObservedObject var viewModel: HenListViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var date = Date()
    @State private var eggNumber = ""
    @State private var isFertile = true
    @State private var developmentStage = DevelopmentStage.day1_3
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Candling Details")) {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    TextField("Egg Number", text: $eggNumber)
                        .keyboardType(.numberPad)
                    
                    Toggle("Fertile", isOn: $isFertile)
                    
                    Picker("Development Stage", selection: $developmentStage) {
                        ForEach(DevelopmentStage.allCases) { stage in
                            Text(stage.rawValue).tag(stage)
                        }
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Add Candling Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCandlingResult()
                    }
                    .disabled(eggNumber.isEmpty)
                }
            }
        }
    }
    
    private func saveCandlingResult() {
        guard let eggNumberInt = Int(eggNumber) else { return }
        
        let result = CandlingResult(
            date: date,
            eggNumber: eggNumberInt,
            isFertile: isFertile,
            developmentStage: developmentStage,
            notes: notes.isEmpty ? nil : notes
        )
        
        var updatedIncubation = incubation
        updatedIncubation.candlingResults.append(result)
        
        viewModel.updateIncubationRecord(updatedIncubation)
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddHatchingView: View {
    let incubation: IncubationRecord
    @ObservedObject var viewModel: HenListViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var hatchDate = Date()
    @State private var chicksCount = ""
    @State private var healthyChicks = ""
    @State private var weakChicks = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Hatching Details")) {
                    DatePicker("Hatch Date", selection: $hatchDate, displayedComponents: .date)
                    
                    TextField("Total Chicks", text: $chicksCount)
                        .keyboardType(.numberPad)
                    
                    TextField("Healthy Chicks", text: $healthyChicks)
                        .keyboardType(.numberPad)
                    
                    TextField("Weak Chicks", text: $weakChicks)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Add Hatching Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveHatchingRecord()
                    }
                    .disabled(chicksCount.isEmpty || healthyChicks.isEmpty)
                }
            }
        }
    }
    
    private func saveHatchingRecord() {
        guard let chicksCountInt = Int(chicksCount),
              let healthyChicksInt = Int(healthyChicks) else { return }
        
        let weakChicksInt = Int(weakChicks) ?? 0
        
        let record = HatchingRecord(
            incubationRecordId: incubation.id,
            hatchDate: hatchDate,
            chicksCount: chicksCountInt,
            healthyChicks: healthyChicksInt,
            weakChicks: weakChicksInt,
            notes: notes.isEmpty ? nil : notes
        )
        
        viewModel.addHatchingRecord(record)
        presentationMode.wrappedValue.dismiss()
    }
} 