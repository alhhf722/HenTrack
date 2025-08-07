import SwiftUI
import PDFKit

struct ExportView: View {
    let hen: Hen
    @ObservedObject var viewModel: HenListViewModel
    @Environment(\.presentationMode) private var presentationMode
    @State private var isExporting = false
    @State private var exportCompleted = false
    @State private var savedPDFURL: URL?
    
    var henNotes: [Note] {
        viewModel.getNotes(for: hen.id)
    }
    
    var henPhotos: [Photo] {
        viewModel.getPhotos(for: hen.id)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    Image(systemName: "photo")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                        .frame(width: 80, height: 80)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                    
                    VStack(spacing: 8) {
                        Text(hen.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(hen.breed)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Circle()
                                .fill(hen.breedingStatus.color)
                                .frame(width: 16, height: 16)
                            
                            Text(hen.breedingStatus.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(hen.breedingStatus.color.opacity(0.2))
                                .foregroundColor(hen.breedingStatus.color)
                                .cornerRadius(8)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("What will be included in the report:")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ExportItem(
                            icon: "info.circle",
                            title: "Basic Information",
                            description: "Name, breed, age, status"
                        )
                        
                        ExportItem(
                            icon: "note.text",
                            title: "Notes",
                            description: "\(henNotes.count) notes"
                        )
                        
                        ExportItem(
                            icon: "photo",
                            title: "Photos",
                            description: "\(henPhotos.count) photos"
                        )
                        
                        ExportItem(
                            icon: "chart.bar",
                            title: "Statistics",
                            description: "Monthly activity analysis"
                        )
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer()
                
                if exportCompleted {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Export Completed!")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("PDF report saved")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if savedPDFURL != nil {
                            VStack(spacing: 12) {
                                Text("PDF saved in Files app")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        shareSavedPDF()
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "square.and.arrow.up")
                                        Text("Send PDF")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                } else {
                    Button(action: exportPDF) {
                        HStack {
                            if isExporting {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "square.and.arrow.up")
                            }
                            
                            Text(isExporting ? "Exporting..." : "Export PDF")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isExporting)
                }
            }
            .padding()
            .navigationTitle("Export Report")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        }
    
    private func exportPDF() {
        isExporting = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let pdfData = createPDF()
            
            DispatchQueue.main.async {
                if let data = pdfData {
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let timestamp = Int(Date().timeIntervalSince1970)
                    let filename = "HenReport_\(hen.name.replacingOccurrences(of: " ", with: "_"))_\(timestamp).pdf"
                    let fileURL = documentsDirectory.appendingPathComponent(filename)
                    
                    do {
                        try data.write(to: fileURL)
                        print("PDF saved: \(fileURL.path)")
                        savedPDFURL = fileURL
                    } catch {
                        print("Error saving PDF: \(error)")
                    }
                }
                
                viewModel.exportHenPDF(hen)
                isExporting = false
                exportCompleted = true
            }
        }
    }
    
    private func createPDF() -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "HenTrack",
            kCGPDFContextAuthor: "HenTrack App",
            kCGPDFContextTitle: "Hen Report \(hen.name)"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            let titleAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)
            ]
            let subtitleAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)
            ]
            let bodyAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)
            ]
            
            var yPosition: CGFloat = 50
            
            // Title
            "Hen Report".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: titleAttributes)
            yPosition += 40
            
            // Hen information
            "Name: \(hen.name)".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: subtitleAttributes)
            yPosition += 25
            "Breed: \(hen.breed)".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: subtitleAttributes)
            yPosition += 25
            "Age: \(hen.age) years".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: subtitleAttributes)
            yPosition += 25
            "Status: \(hen.breedingStatus.rawValue)".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: subtitleAttributes)
            yPosition += 40
            
            // Statistics
            "Statistics:".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: subtitleAttributes)
            yPosition += 25
            "Total notes: \(henNotes.count)".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: bodyAttributes)
            yPosition += 20
            "Total photos: \(henPhotos.count)".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: bodyAttributes)
            yPosition += 40
            
            // Recent notes
            if !henNotes.isEmpty {
                "Recent notes:".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: subtitleAttributes)
                yPosition += 25
                
                for note in henNotes.prefix(5) {
                    let noteText = "\(note.type.rawValue): \(note.title) - \(note.formattedDate)"
                    noteText.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: bodyAttributes)
                    yPosition += 20
                    
                    if yPosition > 750 {
                        context.beginPage()
                        yPosition = 50
                    }
                }
            }
        }
        
        return data
    }
    
    private func shareSavedPDF() {
        guard let pdfURL = savedPDFURL else { return }
        
        let activityVC = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

struct ExportItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct ExportView_Previews: PreviewProvider {
    static var previews: some View {
        ExportView(
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
