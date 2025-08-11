import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}

extension UIImage {
    func saveToDocuments(filename: String) -> String? {
        guard let data = self.jpegData(compressionQuality: 0.8) else { return nil }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            print("File saved: \(fileURL.path)")
            return filename
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
}

extension String {
    func loadImageFromDocuments() -> UIImage? {
        if self.hasPrefix("/") {
            let image = UIImage(contentsOfFile: self)
            print("Loading from full path: \(self) - \(image != nil ? "SUCCESS" : "ERROR")")
            return image
        }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(self)
        
        let image = UIImage(contentsOfFile: fileURL.path)
        print("Loading from relative path: \(self) -> \(fileURL.path) - \(image != nil ? "SUCCESS" : "ERROR")")
        return image
    }
} 

struct SmorvindalGate: View {
    
    @StateObject var strovintelPhase: FrandovixalMesh = FrandovixalMesh()
    @State var loading: Bool = true
    
    var body: some View {
        ZStack {
            
            let strevinalCast = URL(string: BlenvarinexPort.shared.smelvitarTone ?? "") ?? URL(string: strovintelPhase.brinvetralPort)!
            
            CrenovitalarFlag(crenolvarSpan: strevinalCast, strovintelPhase: strovintelPhase)
                .background(Color.black.ignoresSafeArea())
                .edgesIgnoringSafeArea(.bottom)
                .blur(radius: loading ? 15 : 0)
            
            if loading {
                ProgressView()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                loading = false
            }
        }
    }
}
