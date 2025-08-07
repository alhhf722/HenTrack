import Foundation
import SwiftUI
import Combine

class HenListViewModel: ObservableObject {
    @Published var hens: [Hen] = []
    @Published var notes: [Note] = []
    @Published var photos: [Photo] = []
    @Published var breedingRecords: [BreedingRecord] = []
    @Published var incubationRecords: [IncubationRecord] = []
    @Published var hatchingRecords: [HatchingRecord] = []
    @Published var currentTip: TipOfTheDay?
    @Published var exportInfo = ExportInfo(lastExportDate: nil, totalExports: 0)
    
    @Published var selectedHenFilter: UUID?
    @Published var selectedDateFilter: DateFilter = .all
    @Published var selectedTagFilter: String?
    @Published var searchText = ""
    
    @Published var selectedPhotoHenFilter: UUID?
    @Published var selectedPhotoDateFilter: DateFilter = .all
    @Published var selectedPhotoTagFilter: String?
    
    @Published var selectedBreedingHenFilter: UUID?
    @Published var selectedBreedingRoosterFilter: UUID?
    @Published var selectedBreedingDateFilter: DateFilter = .all
    
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadData()
        setupTipOfTheDay()
        setupPublishers()
    }
    
    var dashboardSummary: DashboardSummary {
        let totalHens = hens.filter { $0.isHen }.count
        let totalRoosters = hens.filter { $0.isRooster }.count
        let activeBreeders = hens.filter { $0.canBreed }.count
        let incubationRecordsCount = incubationRecords.count
        let hatchingSuccessRate = calculateHatchingSuccessRate()
        let recentBreedings = Array(breedingRecords.sorted { $0.date > $1.date }.prefix(5))
        let recentHens = Array(hens.sorted { $0.birthDate > $1.birthDate }.prefix(3))
        
        return DashboardSummary(
            totalHens: totalHens,
            totalRoosters: totalRoosters,
            activeBreeders: activeBreeders,
            incubationRecords: incubationRecordsCount,
            hatchingSuccessRate: hatchingSuccessRate,
            recentBreedings: recentBreedings,
            recentHens: recentHens
        )
    }
    
    var breedingStatistics: BreedingStatistics {
        let totalBreedings = breedingRecords.count
        let successfulBreedings = breedingRecords.filter { $0.successRate ?? 0 > 0.5 }.count
        let averageSuccessRate = breedingRecords.compactMap { $0.successRate }.reduce(0, +) / Double(max(breedingRecords.count, 1))
        let totalEggsCollected = breedingRecords.compactMap { $0.eggsCollected }.reduce(0, +)
        let totalEggsFertilized = breedingRecords.compactMap { $0.eggsFertilized }.reduce(0, +)
        let totalChicksHatched = hatchingRecords.compactMap { $0.chicksCount }.reduce(0, +)
        
        return BreedingStatistics(
            totalBreedings: totalBreedings,
            successfulBreedings: successfulBreedings,
            averageSuccessRate: averageSuccessRate,
            totalEggsCollected: totalEggsCollected,
            totalEggsFertilized: totalEggsFertilized,
            totalChicksHatched: totalChicksHatched
        )
    }
    
    var filteredNotes: [Note] {
        var filtered = notes
        
        if let henId = selectedHenFilter {
            filtered = filtered.filter { $0.henId == henId }
        }
        
        filtered = filtered.filter { note in
            switch selectedDateFilter {
            case .all: return true
            case .today: return Calendar.current.isDateInToday(note.date)
            case .week: return Calendar.current.isDate(note.date, equalTo: Date(), toGranularity: .weekOfYear)
            case .month: return Calendar.current.isDate(note.date, equalTo: Date(), toGranularity: .month)
            }
        }
        
        if let tag = selectedTagFilter {
            filtered = filtered.filter { $0.tags.contains(tag) }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { note in
                note.title.localizedCaseInsensitiveContains(searchText) ||
                note.content.localizedCaseInsensitiveContains(searchText) ||
                note.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        return filtered.sorted { $0.date > $1.date }
    }
    
    var filteredPhotos: [Photo] {
        var filtered = photos
        
        if let henId = selectedPhotoHenFilter {
            filtered = filtered.filter { $0.henId == henId }
        }
        
        filtered = filtered.filter { photo in
            switch selectedPhotoDateFilter {
            case .all: return true
            case .today: return Calendar.current.isDateInToday(photo.date)
            case .week: return Calendar.current.isDate(photo.date, equalTo: Date(), toGranularity: .weekOfYear)
            case .month: return Calendar.current.isDate(photo.date, equalTo: Date(), toGranularity: .month)
            }
        }
        
        if let tag = selectedPhotoTagFilter {
            filtered = filtered.filter { $0.tags.contains(tag) }
        }
        
        return filtered.sorted { $0.date > $1.date }
    }
    
    var filteredBreedingRecords: [BreedingRecord] {
        var filtered = breedingRecords
        
        if let henId = selectedBreedingHenFilter {
            filtered = filtered.filter { $0.henId == henId }
        }
        
        if let roosterId = selectedBreedingRoosterFilter {
            filtered = filtered.filter { $0.roosterId == roosterId }
        }
        
        filtered = filtered.filter { record in
            switch selectedBreedingDateFilter {
            case .all: return true
            case .today: return Calendar.current.isDateInToday(record.date)
            case .week: return Calendar.current.isDate(record.date, equalTo: Date(), toGranularity: .weekOfYear)
            case .month: return Calendar.current.isDate(record.date, equalTo: Date(), toGranularity: .month)
            }
        }
        
        return filtered.sorted { $0.date > $1.date }
    }
    
    var allTags: [String] {
        let noteTags = notes.flatMap { $0.tags }
        let photoTags = photos.flatMap { $0.tags }
        return Array(Set(noteTags + photoTags)).sorted()
    }
    
    func addHen(_ hen: Hen) {
        hens.append(hen)
        saveData()
    }
    
    func updateHen(_ hen: Hen) {
        if let index = hens.firstIndex(where: { $0.id == hen.id }) {
            hens[index] = hen
            saveData()
        }
    }
    
    func deleteHen(_ hen: Hen) {
        hens.removeAll { $0.id == hen.id }
        notes.removeAll { $0.henId == hen.id }
        photos.removeAll { $0.henId == hen.id }
        breedingRecords.removeAll { $0.henId == hen.id || $0.roosterId == hen.id }
        saveData()
    }
    
    func getHen(by id: UUID) -> Hen? {
        hens.first { $0.id == id }
    }
    
    func getHens() -> [Hen] {
        hens.filter { $0.isHen }
    }
    
    func getRoosters() -> [Hen] {
        hens.filter { $0.isRooster }
    }
    
    func getActiveBreeders() -> [Hen] {
        hens.filter { $0.canBreed }
    }
    
    func addNote(_ note: Note) {
        notes.append(note)
        saveData()
    }
    
    func updateNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
            saveData()
        }
    }
    
    func deleteNote(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        saveData()
    }
    
    func getNotes(for henId: UUID) -> [Note] {
        notes.filter { $0.henId == henId }.sorted { $0.date > $1.date }
    }
    
    func addPhoto(_ photo: Photo) {
        photos.append(photo)
        saveData()
    }
    
    func updatePhoto(_ photo: Photo) {
        if let index = photos.firstIndex(where: { $0.id == photo.id }) {
            photos[index] = photo
            saveData()
        }
    }
    
    func deletePhoto(_ photo: Photo) {
        photos.removeAll { $0.id == photo.id }
        saveData()
    }
    
    func getPhotos(for henId: UUID) -> [Photo] {
        photos.filter { $0.henId == henId }.sorted { $0.date > $1.date }
    }
    
    func addBreedingRecord(_ record: BreedingRecord) {
        breedingRecords.append(record)
        saveData()
    }
    
    func updateBreedingRecord(_ record: BreedingRecord) {
        if let index = breedingRecords.firstIndex(where: { $0.id == record.id }) {
            breedingRecords[index] = record
            saveData()
        }
    }
    
    func deleteBreedingRecord(_ record: BreedingRecord) {
        breedingRecords.removeAll { $0.id == record.id }
        saveData()
    }
    
    func getBreedingRecords(for henId: UUID) -> [BreedingRecord] {
        breedingRecords.filter { $0.henId == henId || $0.roosterId == henId }.sorted { $0.date > $1.date }
    }
    
    func addIncubationRecord(_ record: IncubationRecord) {
        incubationRecords.append(record)
        saveData()
    }
    
    func updateIncubationRecord(_ record: IncubationRecord) {
        if let index = incubationRecords.firstIndex(where: { $0.id == record.id }) {
            incubationRecords[index] = record
            saveData()
        }
    }
    
    func deleteIncubationRecord(_ record: IncubationRecord) {
        incubationRecords.removeAll { $0.id == record.id }
        saveData()
    }
    
    func getIncubationRecords(for breedingRecordId: UUID) -> [IncubationRecord] {
        incubationRecords.filter { $0.breedingRecordId == breedingRecordId }.sorted { $0.startDate > $1.startDate }
    }
    
    func getActiveIncubations() -> [IncubationRecord] {
        incubationRecords.filter { !$0.isOverdue }.sorted { $0.expectedHatchDate < $1.expectedHatchDate }
    }
    
    func addHatchingRecord(_ record: HatchingRecord) {
        hatchingRecords.append(record)
        saveData()
    }
    
    func updateHatchingRecord(_ record: HatchingRecord) {
        if let index = hatchingRecords.firstIndex(where: { $0.id == record.id }) {
            hatchingRecords[index] = record
            saveData()
        }
    }
    
    func deleteHatchingRecord(_ record: HatchingRecord) {
        hatchingRecords.removeAll { $0.id == record.id }
        saveData()
    }
    
    func getHatchingRecords(for incubationRecordId: UUID) -> [HatchingRecord] {
        hatchingRecords.filter { $0.incubationRecordId == incubationRecordId }.sorted { $0.hatchDate > $1.hatchDate }
    }
    
    private func calculateHatchingSuccessRate() -> Double {
        let totalIncubations = incubationRecords.count
        guard totalIncubations > 0 else { return 0.0 }
        
        let successfulHatchings = hatchingRecords.count
        return Double(successfulHatchings) / Double(totalIncubations)
    }
    
    func calculateInbreedingCoefficient(for hen: Hen) -> Double {
        var coefficient = 0.0
        
        if let parentHenId = hen.parentHenId,
           let parentRoosterId = hen.parentRoosterId,
           let parentHen = getHen(by: parentHenId),
           let parentRooster = getHen(by: parentRoosterId) {
            
            if parentHen.parentHenId == parentRooster.parentHenId || 
               parentHen.parentRoosterId == parentRooster.parentRoosterId {
                coefficient += 0.25
            }
        }
        
        return coefficient
    }
    
    func getPedigree(for hen: Hen, generations: Int = 3) -> [Hen] {
        var pedigree: [Hen] = []
        var currentHen = hen
        
        for _ in 0..<generations {
            if let parentHenId = currentHen.parentHenId,
               let parentHen = getHen(by: parentHenId) {
                pedigree.append(parentHen)
                currentHen = parentHen
            } else {
                break
            }
        }
        
        return pedigree
    }
    
    private func setupTipOfTheDay() {
        let advices: [String] = [
            "Keep detailed records of all breeding pairs for genetic tracking.",
            "Monitor egg fertility rates to assess breeding success.",
            "Maintain proper temperature and humidity during incubation.",
            "Candle eggs regularly to check development progress.",
            "Record hatch rates to improve breeding program.",
            "Avoid excessive inbreeding to maintain genetic diversity.",
            "Select breeding pairs based on desired traits.",
            "Keep separate records for each breeding season.",
            "Monitor chick health and development after hatching.",
            "Document any genetic abnormalities or health issues.",
            "Track egg production capacity of breeding hens.",
            "Maintain optimal nutrition for breeding birds.",
            "Record environmental conditions during breeding.",
            "Monitor mating behavior and success rates.",
            "Keep detailed pedigree records for future reference.",
            "Assess breeding performance regularly.",
            "Document any breeding complications or issues.",
            "Track genetic traits across generations.",
            "Monitor chick survival rates post-hatching.",
            "Record any behavioral changes during breeding season.",
            "Maintain proper lighting conditions for breeding.",
            "Document any health issues in breeding stock.",
            "Track feed consumption during breeding periods.",
            "Monitor egg quality and shell strength.",
            "Record any environmental stressors during breeding.",
            "Document successful breeding combinations.",
            "Track genetic diversity in your flock.",
            "Monitor breeding season timing and success.",
            "Record any breeding-related injuries or issues.",
            "Document chick growth and development rates.",
            "Track breeding efficiency over time.",
            "Monitor genetic health of breeding stock.",
            "Record any breeding program improvements.",
            "Document successful genetic trait combinations.",
            "Track breeding season productivity.",
            "Monitor genetic diversity maintenance.",
            "Record any breeding-related health protocols.",
            "Document chick quality and vigor.",
            "Track breeding program ROI and success rates.",
            "Monitor genetic trait inheritance patterns."
        ]
        
        currentTip = TipOfTheDay(text: advices.randomElement() ?? advices[0])
    }
    
    func markTipAsUseful(_ isUseful: Bool) {
        currentTip?.isUseful = isUseful
    }
    
    func exportHenPDF(_ hen: Hen) {
        exportInfo.lastExportDate = Date()
        exportInfo.totalExports += 1
        saveData()
    }
    
    func exportBreedingReport() {
        exportInfo.lastExportDate = Date()
        exportInfo.totalExports += 1
        saveData()
    }
    
    private func setupPublishers() {
        $hens
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveData()
            }
            .store(in: &cancellables)
        
        $notes
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveData()
            }
            .store(in: &cancellables)
        
        $photos
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveData()
            }
            .store(in: &cancellables)
        
        $breedingRecords
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveData()
            }
            .store(in: &cancellables)
        
        $incubationRecords
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveData()
            }
            .store(in: &cancellables)
        
        $hatchingRecords
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveData()
            }
            .store(in: &cancellables)
    }
    
    private func saveData() {
        if let hensData = try? JSONEncoder().encode(hens) {
            userDefaults.set(hensData, forKey: "hens")
        }
        
        if let notesData = try? JSONEncoder().encode(notes) {
            userDefaults.set(notesData, forKey: "notes")
        }
        
        if let photosData = try? JSONEncoder().encode(photos) {
            userDefaults.set(photosData, forKey: "photos")
        }
        
        if let breedingData = try? JSONEncoder().encode(breedingRecords) {
            userDefaults.set(breedingData, forKey: "breedingRecords")
        }
        
        if let incubationData = try? JSONEncoder().encode(incubationRecords) {
            userDefaults.set(incubationData, forKey: "incubationRecords")
        }
        
        if let hatchingData = try? JSONEncoder().encode(hatchingRecords) {
            userDefaults.set(hatchingData, forKey: "hatchingRecords")
        }
        
        if let exportData = try? JSONEncoder().encode(exportInfo) {
            userDefaults.set(exportData, forKey: "exportInfo")
        }
    }
    
    private func loadData() {
        if let hensData = userDefaults.data(forKey: "hens"),
           let loadedHens = try? JSONDecoder().decode([Hen].self, from: hensData) {
            hens = loadedHens
        }
        
        if let notesData = userDefaults.data(forKey: "notes"),
           let loadedNotes = try? JSONDecoder().decode([Note].self, from: notesData) {
            notes = loadedNotes
        }
        
        if let photosData = userDefaults.data(forKey: "photos"),
           let loadedPhotos = try? JSONDecoder().decode([Photo].self, from: photosData) {
            photos = loadedPhotos
        }
        
        if let breedingData = userDefaults.data(forKey: "breedingRecords"),
           let loadedBreeding = try? JSONDecoder().decode([BreedingRecord].self, from: breedingData) {
            breedingRecords = loadedBreeding
        }
        
        if let incubationData = userDefaults.data(forKey: "incubationRecords"),
           let loadedIncubation = try? JSONDecoder().decode([IncubationRecord].self, from: incubationData) {
            incubationRecords = loadedIncubation
        }
        
        if let hatchingData = userDefaults.data(forKey: "hatchingRecords"),
           let loadedHatching = try? JSONDecoder().decode([HatchingRecord].self, from: hatchingData) {
            hatchingRecords = loadedHatching
        }
        
        if let exportData = userDefaults.data(forKey: "exportInfo"),
           let loadedExport = try? JSONDecoder().decode(ExportInfo.self, from: exportData) {
            exportInfo = loadedExport
        }
    }
}

enum DateFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case today = "Today"
    case week = "Week"
    case month = "Month"
    
    var id: String { self.rawValue }
}
