import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: HenListViewModel
    @State private var showingAddHen = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    TipOfTheDayCard(tip: viewModel.currentTip)
                    
                    SummaryCard(summary: viewModel.dashboardSummary)
                    
                    BreedingStatsCard(statistics: viewModel.breedingStatistics)
                    
                    RecentBreedingsCard(
                        breedings: viewModel.dashboardSummary.recentBreedings,
                        viewModel: viewModel
                    )
                    
                    RecentHensCard(
                        hens: viewModel.dashboardSummary.recentHens,
                        viewModel: viewModel
                    )
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAddHen) {
                AddHenView(viewModel: viewModel)
            }
        }
    }
}

struct TipOfTheDayCard: View {
    let tip: TipOfTheDay?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Breeding Tip of the Day")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            if let tip = tip {
                Text(tip.text)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            } else {
                Text("Loading tip...")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct SummaryCard: View {
    let summary: DashboardSummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.blue)
                Text("Breeding Stock Summary")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                SummaryRow(
                    icon: "🐔",
                    title: "Total Hens",
                    value: "\(summary.totalHens)"
                )
                
                SummaryRow(
                    icon: "🐓",
                    title: "Total Roosters",
                    value: "\(summary.totalRoosters)"
                )
                
                SummaryRow(
                    icon: "❤️",
                    title: "Active Breeders",
                    value: "\(summary.activeBreeders)"
                )
                
                SummaryRow(
                    icon: "🥚",
                    title: "Active Incubations",
                    value: "\(summary.incubationRecords)"
                )
                
                SummaryRow(
                    icon: "🐣",
                    title: "Hatching Success Rate",
                    value: "\(Int(summary.hatchingSuccessRate * 100))%"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct BreedingStatsCard: View {
    let statistics: BreedingStatistics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.pink)
                Text("Breeding Statistics")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                SummaryRow(
                    icon: "❤️",
                    title: "Total Breedings",
                    value: "\(statistics.totalBreedings)"
                )
                
                SummaryRow(
                    icon: "✅",
                    title: "Successful Breedings",
                    value: "\(statistics.successfulBreedings)"
                )
                
                SummaryRow(
                    icon: "📊",
                    title: "Average Success Rate",
                    value: "\(Int(statistics.averageSuccessRate * 100))%"
                )
                
                SummaryRow(
                    icon: "🥚",
                    title: "Eggs Collected",
                    value: "\(statistics.totalEggsCollected)"
                )
                
                SummaryRow(
                    icon: "🐣",
                    title: "Chicks Hatched",
                    value: "\(statistics.totalChicksHatched)"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct SummaryRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(icon)
                .font(.title2)
            
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

struct RecentBreedingsCard: View {
    let breedings: [BreedingRecord]
    let viewModel: HenListViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.pink)
                Text("Recent Breedings")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                
                NavigationLink("All", destination: BreedingListView(viewModel: viewModel))
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            
            if breedings.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "heart.circle")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    
                    Text("No breeding records yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(breedings) { breeding in
                        BreedingRowView(breeding: breeding, viewModel: viewModel)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct BreedingRowView: View {
    let breeding: BreedingRecord
    let viewModel: HenListViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "heart.fill")
                .font(.title2)
                .foregroundColor(.pink)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(henName) × \(roosterName)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if let successRate = breeding.successRate {
                        Text("\(Int(successRate * 100))%")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(successRate > 0.7 ? Color.green : successRate > 0.4 ? Color.orange : Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                
                Text(breeding.formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var henName: String {
        viewModel.getHen(by: breeding.henId)?.name ?? "Unknown Hen"
    }
    
    private var roosterName: String {
        viewModel.getHen(by: breeding.roosterId)?.name ?? "Unknown Rooster"
    }
}

struct RecentHensCard: View {
    let hens: [Hen]
    let viewModel: HenListViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.orange)
                Text("Recent Breeding Stock")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                
                NavigationLink("All", destination: HensListView(viewModel: viewModel))
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            
            if hens.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "plus.circle")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    
                    Text("Add your first chicken")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(hens) { hen in
                        HenRowView(hen: hen, viewModel: viewModel)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct HenRowView: View {
    let hen: Hen
    let viewModel: HenListViewModel
    
    var body: some View {
        NavigationLink(destination: HenDetailView(hen: hen, viewModel: viewModel)) {
            HStack(spacing: 12) {
                Group {
                    if let localPhotoPath = hen.localPhotoPath,
                       let image = localPhotoPath.loadImageFromDocuments() {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 50, height: 50)
                .background(Color(.systemGray5))
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(hen.name)
                            .font(.headline)
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
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(viewModel: HenListViewModel())
    }
} 
