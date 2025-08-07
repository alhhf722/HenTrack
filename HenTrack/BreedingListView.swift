import SwiftUI

struct BreedingListView: View {
    @ObservedObject var viewModel: HenListViewModel
    @State private var showingAddBreeding = false
    @State private var selectedBreedingRecord: BreedingRecord?
    
    var body: some View {
        List {
            Section(header: Text("Breeding Statistics")) {
                BreedingStatsView(viewModel: viewModel)
            }
            
            Section(header: Text("Recent Breedings")) {
                ForEach(viewModel.filteredBreedingRecords) { record in
                    BreedingRecordRow(record: record, viewModel: viewModel)
                        .onTapGesture {
                            selectedBreedingRecord = record
                        }
                }
                .onDelete(perform: deleteBreedingRecords)
            }
        }
        .navigationTitle("Breeding Records")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddBreeding = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddBreeding) {
            AddBreedingView(viewModel: viewModel)
        }
        .sheet(item: $selectedBreedingRecord) { record in
            BreedingDetailView(record: record, viewModel: viewModel)
        }
    }
    
    private func deleteBreedingRecords(offsets: IndexSet) {
        for index in offsets {
            let record = viewModel.filteredBreedingRecords[index]
            viewModel.deleteBreedingRecord(record)
        }
    }
}

struct BreedingStatsView: View {
    @ObservedObject var viewModel: HenListViewModel
    
    var body: some View {
        let stats = viewModel.breedingStatistics
        
        VStack(spacing: 12) {
            HStack {
                StatCard(
                    title: "Total Breedings",
                    value: "\(stats.totalBreedings)",
                    icon: "heart.fill",
                    color: .pink
                )
                
                StatCard(
                    title: "Success Rate",
                    value: "\(Int(stats.averageSuccessRate * 100))%",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                )
            }
            
            HStack {
                StatCard(
                    title: "Eggs Collected",
                    value: "\(stats.totalEggsCollected)",
                    icon: "egg.fill",
                    color: .yellow
                )
                
                StatCard(
                    title: "Chicks Hatched",
                    value: "\(stats.totalChicksHatched)",
                    icon: "bird.fill",
                    color: .orange
                )
            }
        }
        .padding(.vertical, 8)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct BreedingRecordRow: View {
    let record: BreedingRecord
    @ObservedObject var viewModel: HenListViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(henName) × \(roosterName)")
                        .font(.headline)
                    
                    Text(record.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    if let successRate = record.successRate {
                        Text("\(Int(successRate * 100))%")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(successRate > 0.7 ? Color.green : successRate > 0.4 ? Color.orange : Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    if let eggsCollected = record.eggsCollected {
                        Text("\(eggsCollected) eggs")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if let notes = record.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var henName: String {
        viewModel.getHen(by: record.henId)?.name ?? "Unknown Hen"
    }
    
    private var roosterName: String {
        viewModel.getHen(by: record.roosterId)?.name ?? "Unknown Rooster"
    }
}

struct BreedingDetailView: View {
    let record: BreedingRecord
    @ObservedObject var viewModel: HenListViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingEdit = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Breeding Pair Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Breeding Pair")
                            .font(.headline)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Hen: \(henName)")
                                    .font(.subheadline)
                                Text("Breed: \(henBreed)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right")
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Rooster: \(roosterName)")
                                    .font(.subheadline)
                                Text("Breed: \(roosterBreed)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    // Breeding Details
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Breeding Details")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            DetailRow(title: "Date", value: record.formattedDate)
                            
                            if let successRate = record.successRate {
                                DetailRow(title: "Success Rate", value: "\(Int(successRate * 100))%")
                            }
                            
                            if let eggsCollected = record.eggsCollected {
                                DetailRow(title: "Eggs Collected", value: "\(eggsCollected)")
                            }
                            
                            if let eggsFertilized = record.eggsFertilized {
                                DetailRow(title: "Eggs Fertilized", value: "\(eggsFertilized)")
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    // Notes
                    if let notes = record.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)
                            
                            Text(notes)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                    }
                    
                    // Related Incubations
                    let relatedIncubations = viewModel.getIncubationRecords(for: record.id)
                    if !relatedIncubations.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Related Incubations")
                                .font(.headline)
                            
                            ForEach(relatedIncubations) { incubation in
                                IncubationRow(incubation: incubation, viewModel: viewModel)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Breeding Details")
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
            EditBreedingView(record: record, viewModel: viewModel)
        }
    }
    
    private var henName: String {
        viewModel.getHen(by: record.henId)?.name ?? "Unknown Hen"
    }
    
    private var henBreed: String {
        viewModel.getHen(by: record.henId)?.breed ?? "Unknown"
    }
    
    private var roosterName: String {
        viewModel.getHen(by: record.roosterId)?.name ?? "Unknown Rooster"
    }
    
    private var roosterBreed: String {
        viewModel.getHen(by: record.roosterId)?.breed ?? "Unknown"
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct IncubationRow: View {
    let incubation: IncubationRecord
    @ObservedObject var viewModel: HenListViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Started: \(incubation.startDate, style: .date)")
                    .font(.subheadline)
                Text("Expected: \(incubation.expectedHatchDate, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(incubation.eggsCount) eggs")
                    .font(.subheadline)
                
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
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(8)
    }
}

struct AddBreedingView: View {
    @ObservedObject var viewModel: HenListViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedHenId: UUID?
    @State private var selectedRoosterId: UUID?
    @State private var date = Date()
    @State private var notes = ""
    @State private var successRate: Double = 0.0
    @State private var eggsCollected: String = ""
    @State private var eggsFertilized: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Breeding Pair")) {
                    // Debug information
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Debug Info:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Total hens: \(viewModel.getHens().count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Breedable hens: \(viewModel.getHens().filter { $0.canBreed }.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Total roosters: \(viewModel.getRoosters().count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Breedable roosters: \(viewModel.getRoosters().filter { $0.canBreed }.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // Show details for each hen
                        if !viewModel.getHens().isEmpty {
                            Text("Hens details:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            ForEach(viewModel.getHens()) { hen in
                                Text("\(hen.name): status=\(hen.breedingStatus.rawValue), age=\(hen.age), canBreed=\(hen.canBreed)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Show details for each rooster
                        if !viewModel.getRoosters().isEmpty {
                            Text("Roosters details:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            ForEach(viewModel.getRoosters()) { rooster in
                                Text("\(rooster.name): status=\(rooster.breedingStatus.rawValue), age=\(rooster.age), canBreed=\(rooster.canBreed)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    
                    Picker("Hen", selection: $selectedHenId) {
                        Text("Select Hen").tag(nil as UUID?)
                        ForEach(viewModel.getHens().filter { $0.canBreed }) { hen in
                            Text(hen.name).tag(hen.id as UUID?)
                        }
                    }
                    
                    Picker("Rooster", selection: $selectedRoosterId) {
                        Text("Select Rooster").tag(nil as UUID?)
                        ForEach(viewModel.getRoosters().filter { $0.canBreed }) { rooster in
                            Text(rooster.name).tag(rooster.id as UUID?)
                        }
                    }
                }
                
                Section(header: Text("Breeding Details")) {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    VStack(alignment: .leading) {
                        Text("Success Rate: \(Int(successRate * 100))%")
                        Slider(value: $successRate, in: 0...1, step: 0.1)
                    }
                    
                    TextField("Eggs Collected", text: $eggsCollected)
                        .keyboardType(.numberPad)
                    
                    TextField("Eggs Fertilized", text: $eggsFertilized)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Add Breeding Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveBreedingRecord()
                    }
                    .disabled(selectedHenId == nil || selectedRoosterId == nil)
                }
            }
        }
    }
    
    private func saveBreedingRecord() {
        guard let henId = selectedHenId,
              let roosterId = selectedRoosterId else { return }
        
        let record = BreedingRecord(
            henId: henId,
            roosterId: roosterId,
            date: date,
            notes: notes.isEmpty ? nil : notes,
            successRate: successRate > 0 ? successRate : nil,
            eggsCollected: Int(eggsCollected),
            eggsFertilized: Int(eggsFertilized)
        )
        
        viewModel.addBreedingRecord(record)
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditBreedingView: View {
    let record: BreedingRecord
    @ObservedObject var viewModel: HenListViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedHenId: UUID
    @State private var selectedRoosterId: UUID
    @State private var date: Date
    @State private var notes: String
    @State private var successRate: Double
    @State private var eggsCollected: String
    @State private var eggsFertilized: String
    
    init(record: BreedingRecord, viewModel: HenListViewModel) {
        self.record = record
        self.viewModel = viewModel
        
        _selectedHenId = State(initialValue: record.henId)
        _selectedRoosterId = State(initialValue: record.roosterId)
        _date = State(initialValue: record.date)
        _notes = State(initialValue: record.notes ?? "")
        _successRate = State(initialValue: record.successRate ?? 0.0)
        _eggsCollected = State(initialValue: record.eggsCollected?.description ?? "")
        _eggsFertilized = State(initialValue: record.eggsFertilized?.description ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Breeding Pair")) {
                    Picker("Hen", selection: $selectedHenId) {
                        ForEach(viewModel.getHens().filter { $0.canBreed }) { hen in
                            Text(hen.name).tag(hen.id)
                        }
                    }
                    
                    Picker("Rooster", selection: $selectedRoosterId) {
                        ForEach(viewModel.getRoosters().filter { $0.canBreed }) { rooster in
                            Text(rooster.name).tag(rooster.id)
                        }
                    }
                }
                
                Section(header: Text("Breeding Details")) {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    VStack(alignment: .leading) {
                        Text("Success Rate: \(Int(successRate * 100))%")
                        Slider(value: $successRate, in: 0...1, step: 0.1)
                    }
                    
                    TextField("Eggs Collected", text: $eggsCollected)
                        .keyboardType(.numberPad)
                    
                    TextField("Eggs Fertilized", text: $eggsFertilized)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Edit Breeding Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveBreedingRecord()
                    }
                }
            }
        }
    }
    
    private func saveBreedingRecord() {
        var updatedRecord = record
        updatedRecord.henId = selectedHenId
        updatedRecord.roosterId = selectedRoosterId
        updatedRecord.date = date
        updatedRecord.notes = notes.isEmpty ? nil : notes
        updatedRecord.successRate = successRate > 0 ? successRate : nil
        updatedRecord.eggsCollected = Int(eggsCollected)
        updatedRecord.eggsFertilized = Int(eggsFertilized)
        
        viewModel.updateBreedingRecord(updatedRecord)
        presentationMode.wrappedValue.dismiss()
    }
} 