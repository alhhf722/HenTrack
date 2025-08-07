import Foundation
import SwiftUI

// MARK: - Main Models

struct Hen: Identifiable, Codable {
    let id = UUID()
    var name: String
    var breed: String
    var birthDate: Date
    var gender: ChickenGender
    var featherColor: String
    var weight: Double?
    var breedingStatus: BreedingStatus
    var parentHenId: UUID?
    var parentRoosterId: UUID?
    var generation: Int
    var eggLayingCapacity: EggLayingCapacity
    var photoURL: String?
    var localPhotoPath: String?
    var notes: [Note] = []
    var photos: [Photo] = []
    var breedingRecords: [BreedingRecord] = []
    
    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }
    
    var isActive: Bool {
        breedingStatus == .active
    }
    
    var isBreeder: Bool {
        breedingStatus == .active && age >= 1
    }
}

struct Note: Identifiable, Codable {
    let id = UUID()
    var title: String
    var content: String
    var date: Date
    var henId: UUID
    var tags: [String] = []
    var photoURL: String?
    var type: NoteType
    
    var hashtags: [String] {
        tags.map { "#\($0)" }
    }
}

struct Photo: Identifiable, Codable {
    let id = UUID()
    var imageURL: String?
    var localPhotoPath: String?
    var date: Date
    var henId: UUID
    var caption: String?
    var tags: [String] = []
}

// MARK: - Breeding Models

struct BreedingRecord: Identifiable, Codable {
    let id = UUID()
    var henId: UUID
    var roosterId: UUID
    var date: Date
    var notes: String?
    var successRate: Double?
    var eggsCollected: Int?
    var eggsFertilized: Int?
}

struct IncubationRecord: Identifiable, Codable {
    let id = UUID()
    var breedingRecordId: UUID
    var startDate: Date
    var expectedHatchDate: Date
    var temperature: Double?
    var humidity: Double?
    var eggsCount: Int
    var candlingResults: [CandlingResult] = []
    var notes: String?
}

struct CandlingResult: Identifiable, Codable {
    let id = UUID()
    var date: Date
    var eggNumber: Int
    var isFertile: Bool
    var developmentStage: DevelopmentStage
    var notes: String?
}

struct HatchingRecord: Identifiable, Codable {
    let id = UUID()
    var incubationRecordId: UUID
    var hatchDate: Date
    var chicksCount: Int
    var healthyChicks: Int
    var weakChicks: Int
    var notes: String?
    var chickIds: [UUID] = []
}

// MARK: - Enums

enum ChickenGender: String, Codable, CaseIterable, Identifiable {
    case hen = "Hen"
    case rooster = "Rooster"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .hen: return "🐔"
        case .rooster: return "🐓"
        }
    }
}

enum BreedingStatus: String, Codable, CaseIterable, Identifiable {
    case active = "Active"
    case inactive = "Inactive"
    case retired = "Retired"
    case deceased = "Deceased"
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .active: return .green
        case .inactive: return .orange
        case .retired: return .gray
        case .deceased: return .red
        }
    }
}

enum EggLayingCapacity: String, Codable, CaseIterable, Identifiable {
    case excellent = "Excellent"
    case good = "Good"
    case average = "Average"
    case poor = "Poor"
    case unknown = "Unknown"
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .excellent: return .green
        case .good: return .blue
        case .average: return .yellow
        case .poor: return .red
        case .unknown: return .gray
        }
    }
}

enum DevelopmentStage: String, Codable, CaseIterable, Identifiable {
    case day1_3 = "Day 1-3"
    case day4_7 = "Day 4-7"
    case day8_14 = "Day 8-14"
    case day15_21 = "Day 15-21"
    
    var id: String { self.rawValue }
}

enum NoteType: String, Codable, CaseIterable, Identifiable {
    case breeding = "Breeding"
    case incubation = "Incubation"
    case hatching = "Hatching"
    case genetics = "Genetics"
    case pedigree = "Pedigree"
    case health = "Health"
    case behavior = "Behavior"
    case feeding = "Feeding"
    case general = "General"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .breeding: return "❤️"
        case .incubation: return "🥚"
        case .hatching: return "🐣"
        case .genetics: return "🧬"
        case .pedigree: return "👨‍👩‍👧‍👦"
        case .health: return "🏥"
        case .behavior: return "🐓"
        case .feeding: return "🌾"
        case .general: return "📝"
        }
    }
    
    var color: Color {
        switch self {
        case .breeding: return .pink
        case .incubation: return .yellow
        case .hatching: return .orange
        case .genetics: return .purple
        case .pedigree: return .blue
        case .health: return .red
        case .behavior: return .blue
        case .feeding: return .green
        case .general: return .gray
        }
    }
}

// MARK: - Helper Structures

struct TipOfTheDay: Identifiable {
    let id = UUID()
    let text: String
    var isUseful: Bool?
}

struct DashboardSummary {
    let totalHens: Int
    let totalRoosters: Int
    let activeBreeders: Int
    let incubationRecords: Int
    let hatchingSuccessRate: Double
    let recentBreedings: [BreedingRecord]
    let recentHens: [Hen]
}

struct ExportInfo: Codable {
    var lastExportDate: Date?
    var totalExports: Int
}

struct BreedingStatistics {
    let totalBreedings: Int
    let successfulBreedings: Int
    let averageSuccessRate: Double
    let totalEggsCollected: Int
    let totalEggsFertilized: Int
    let totalChicksHatched: Int
}

// MARK: - Extensions for Convenience

extension Hen {
    var notesCount: Int {
        notes.count
    }
    
    var photosCount: Int {
        photos.count
    }
    
    var recentNotes: [Note] {
        notes.sorted { $0.date > $1.date }.prefix(5).map { $0 }
    }
    
    var monthlyNotesCount: Int {
        let calendar = Calendar.current
        let now = Date()
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        
        return notes.filter { $0.date >= monthAgo }.count
    }
    
    var isHen: Bool {
        gender == .hen
    }
    
    var isRooster: Bool {
        gender == .rooster
    }
    
    var canBreed: Bool {
        breedingStatus == .active && age >= 1
    }
    
    var breedingRecordsCount: Int {
        breedingRecords.count
    }
    
    var recentBreedings: [BreedingRecord] {
        breedingRecords.sorted { $0.date > $1.date }.prefix(3).map { $0 }
    }
}

extension Note {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

extension Photo {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

extension BreedingRecord {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var successRatePercentage: String {
        guard let rate = successRate else { return "N/A" }
        return "\(Int(rate * 100))%"
    }
}

extension IncubationRecord {
    var daysUntilHatch: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: Date(), to: expectedHatchDate).day ?? 0
    }
    
    var isHatchingSoon: Bool {
        daysUntilHatch <= 3 && daysUntilHatch >= 0
    }
    
    var isOverdue: Bool {
        daysUntilHatch < 0
    }
} 
