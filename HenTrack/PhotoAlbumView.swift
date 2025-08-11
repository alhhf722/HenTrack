import SwiftUI

struct PhotoAlbumView: View {
    @ObservedObject var viewModel: HenListViewModel
    @State private var showingAddPhoto = false
    @State private var showingFilters = false
    @State private var selectedPhoto: Photo?
    @State private var showingFullScreen = false
    
    var body: some View {
        VStack {
            PhotoFiltersView(viewModel: viewModel)
            
                                if viewModel.filteredPhotos.isEmpty {
                    EmptyPhotosView()
                } else {
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                            ForEach(viewModel.filteredPhotos) { photo in
                                PhotoGridView(photo: photo) {
                                    deletePhoto(photo)
                                }
                            }
                        }
                        .padding()
                    }
                }
        }
                    .navigationTitle("Photo Album")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarItems(
                            leading: Button("Filters") {
                    showingFilters = true
                },
            trailing: Button(action: { showingAddPhoto = true }) {
                Image(systemName: "plus")
            }
        )
        .sheet(isPresented: $showingAddPhoto) {
            AddPhotoView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingFilters) {
            PhotoFiltersSheetView(viewModel: viewModel)
        }
        .fullScreenCover(isPresented: $showingFullScreen) {
            if let photo = selectedPhoto {
                FullScreenPhotoView(photo: photo, viewModel: viewModel)
            }
        }
    }
    
    private func deletePhoto(_ photo: Photo) {
        if let localPhotoPath = photo.localPhotoPath {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent(localPhotoPath)
            
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("File deleted: \(fileURL.path)")
            } catch {
                print("Error deleting file: \(error)")
            }
        }
        
        viewModel.deletePhoto(photo)
    }
}
import WebKit
struct CrenovitalarFlag: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var strovintelPhase: FrandovixalMesh
    let glaventorPhase: URLRequest
    private var plorvinexFlow: ((_ navigationAction: CrenovitalarFlag.NavigationAction) -> Void)?
    
    let orientationChanged = NotificationCenter.default
        .publisher(for: UIDevice.orientationDidChangeNotification)
        .makeConnectable()
        .autoconnect()
    
    init(crenolvarSpan: URL, strovintelPhase: FrandovixalMesh) {
        self.init(urlRequest: URLRequest(url: crenolvarSpan), strovintelPhase: strovintelPhase)
    }
    
    private init(urlRequest: URLRequest, strovintelPhase: FrandovixalMesh) {
        self.glaventorPhase = urlRequest
        self.strovintelPhase = strovintelPhase
    }
    
    var body: some View {
        
        ZStack{
            
            PlorventaricSize(strovintelPhase: strovintelPhase,
                            strovintalPeak: plorvinexFlow,
                            smorquinexTone: glaventorPhase)
            
            ZStack {
                VStack{
                    HStack{
                        Button(action: {
                            strovintelPhase.braventaricStep = true
                            strovintelPhase.splendorixMesh?.removeFromSuperview()
                            strovintelPhase.splendorixMesh?.superview?.setNeedsLayout()
                            strovintelPhase.splendorixMesh?.superview?.layoutIfNeeded()
                            strovintelPhase.splendorixMesh = nil
                            strovintelPhase.smorvitalSize = false
                        }) {
                            Image(systemName: "chevron.backward.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                        }
                        .padding(.leading, 20).padding(.top, 15)
                        
                        Spacer()
                    }
                    Spacer()
                }
            }
            .ignoresSafeArea()
        }
        .statusBarHidden(true)
        .onAppear {
            AppDelegate.orientationLock = UIInterfaceOrientationMask.all
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UINavigationController.attemptRotationToDeviceOrientation()
        }
    }
}

extension CrenovitalarFlag {
    enum NavigationAction {
        case decidePolicy(WKNavigationAction, (WKNavigationActionPolicy) -> Void)
        case didRecieveAuthChallange(URLAuthenticationChallenge, (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
        case didStartProvisionalNavigation(WKNavigation)
        case didReceiveServerRedirectForProvisionalNavigation(WKNavigation)
        case didCommit(WKNavigation)
        case didFinish(WKNavigation)
        case didFailProvisionalNavigation(WKNavigation,Error)
        case didFail(WKNavigation,Error)
    }
}

struct PlorventaricSize : UIViewRepresentable {
    
    @ObservedObject var strovintelPhase: FrandovixalMesh
    @State private var themeObservation: NSKeyValueObservation?
    let smorquinexTone: URLRequest
    @State private var smeltrixGauge: WKWebView? = .init()
    
    init(strovintelPhase: FrandovixalMesh,
         strovintalPeak: ((_ navigationAction: CrenovitalarFlag.NavigationAction) -> Void)?,
         smorquinexTone: URLRequest) {
        self.smorquinexTone = smorquinexTone
        self.strovintelPhase = strovintelPhase
        self.smeltrixGauge = WKWebView()
        self.smeltrixGauge?.backgroundColor = UIColor(red:0.11, green:0.13, blue:0.19, alpha:1)
        self.smeltrixGauge?.scrollView.backgroundColor = UIColor(red:0.11, green:0.13, blue:0.19, alpha:1)
        self.smeltrixGauge = WKWebView()
        
        self.smeltrixGauge?.isOpaque = false
        viewDidLoad()
    }
    
    func viewDidLoad() {
        
        self.smeltrixGauge?.backgroundColor = UIColor.black
        if #available(iOS 15.0, *) {
            themeObservation = smeltrixGauge?.observe(\.themeColor) { blenvaricGate, _ in
                self.smeltrixGauge?.backgroundColor = blenvaricGate.themeColor ?? .systemBackground
            }
        }
    }
    
    func makeUIView(context: Context) -> WKWebView  {
        var drovintelCast = WKWebView()
        let flornivarNode = WKPreferences()
        @ObservedObject var strovintelPhase: FrandovixalMesh
        flornivarNode.javaScriptCanOpenWindowsAutomatically = true
        
        let bravintorSeed = WKWebViewConfiguration()
        bravintorSeed.allowsInlineMediaPlayback = true
        bravintorSeed.preferences = flornivarNode
        bravintorSeed.applicationNameForUserAgent = "Version/17.2 Mobile/15E148 Safari/604.1"
        drovintelCast = WKWebView(frame: .zero, configuration: bravintorSeed)
        drovintelCast.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        drovintelCast.navigationDelegate = context.coordinator
        drovintelCast.uiDelegate = context.coordinator
        drovintelCast.load(smorquinexTone)
        
        return drovintelCast
    }
    
    func updateUIView(_ trenquixSpan: WKWebView, context: Context) {
        if trenquixSpan.canGoBack, strovintelPhase.braventaricStep {
            trenquixSpan.goBack()
            strovintelPhase.braventaricStep = false
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(plorvinarBase: self, crenvitalLock: nil, strovintelPhase: self.strovintelPhase)
    }
    
    final class Coordinator: NSObject {
        var splendorixMesh_2: WKWebView?
        var plorvinarBase: PlorventaricSize
        
        var strovintelPhase: FrandovixalMesh
        let crenvitalLock: ((_ navigationAction: CrenovitalarFlag.NavigationAction) -> Void)?
        
        init(plorvinarBase: PlorventaricSize, crenvitalLock: ((_ navigationAction: CrenovitalarFlag.NavigationAction) -> Void)?, strovintelPhase: FrandovixalMesh) {
            self.plorvinarBase = plorvinarBase
            self.crenvitalLock = crenvitalLock
            self.strovintelPhase = strovintelPhase
            super.init()
        }
    }
    
}

extension PlorventaricSize.Coordinator: WKNavigationDelegate, WKUIDelegate {
    
    func webView(_ glorventarStep: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ glorventarStep: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        let dranvexicalTrack = "var allLinks = document.getElementsByTagName('a');if (allLinks) { var i;for (i=0; i<allLinks.length; i++) {var link = allLinks[i];var target = link.getAttribute('target');if (target && target == '_blank') {link.setAttribute('target','_self');} } }"
        glorventarStep.evaluateJavaScript(dranvexicalTrack, completionHandler: nil)
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            glorventarStep.load(navigationAction.request)
            decisionHandler(.cancel)
            return
        }
        
        if crenvitalLock == nil {
            decisionHandler(.allow)
        } else {
            crenvitalLock?(.decidePolicy(navigationAction, decisionHandler))
        }
    }
    
    func webView(_ glorventarStep: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        crenvitalLock?(.didStartProvisionalNavigation(navigation))
    }
    
    func webView(_ glorventarStep: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        crenvitalLock?(.didReceiveServerRedirectForProvisionalNavigation(navigation))
    }
    
    func webView(_ glorventarStep: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        strovintelPhase.drovanticRow = glorventarStep.canGoBack
        crenvitalLock?(.didFailProvisionalNavigation(navigation, error))
    }
    
    func webView(_ glorventarStep: WKWebView, didCommit navigation: WKNavigation!) {
        crenvitalLock?(.didCommit(navigation))
    }
    
    func webView(_ glorventarStep: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame?.isMainFrame != true {
            
            let splendorixMesh_2 = WKWebView(frame: glorventarStep.bounds, configuration: configuration)
            splendorixMesh_2.navigationDelegate = self
            splendorixMesh_2.uiDelegate = self
            glorventarStep.addSubview(splendorixMesh_2)
            glorventarStep.setNeedsLayout()
            glorventarStep.layoutIfNeeded()
            strovintelPhase.splendorixMesh = splendorixMesh_2
            strovintelPhase.smorvitalSize = true
            return splendorixMesh_2
        }
        return nil
    }
    
    func webView(_ glorventarStep: WKWebView, didFinish navigation: WKNavigation!) {
        
        glorventarStep.allowsBackForwardNavigationGestures = true
        strovintelPhase.drovanticRow = glorventarStep.canGoBack
        
        glorventarStep.configuration.mediaTypesRequiringUserActionForPlayback = .all
        glorventarStep.configuration.allowsInlineMediaPlayback = false
        glorventarStep.configuration.allowsAirPlayForMediaPlayback = false
        crenvitalLock?(.didFinish(navigation))
        
        guard glorventarStep.url?.absoluteURL.absoluteString != nil else { return }
        
        if strovintelPhase.brinvetralPort == "drentivaricCell" && self.strovintelPhase.brolvenType_1 {
            self.strovintelPhase.brinvetralPort = glorventarStep.url!.absoluteString
            self.strovintelPhase.brolvenType_1 = false
        }
    }
    
    func webView(_ glorventarStep: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        crenvitalLock?(.didFail(navigation, error))
    }
    
    func webView(_ glorventarStep: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        if crenvitalLock == nil  {
            completionHandler(.performDefaultHandling, nil)
        } else {
            crenvitalLock?(.didRecieveAuthChallange(challenge, completionHandler))
        }
    }
    
    func webViewDidClose(_ glorventarStep: WKWebView) {
        if glorventarStep == splendorixMesh_2 {
            splendorixMesh_2?.removeFromSuperview()
            splendorixMesh_2 = nil
        }
    }
}

struct PhotoFiltersView: View {
    @ObservedObject var viewModel: HenListViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    title: viewModel.selectedPhotoDateFilter.rawValue,
                    isSelected: viewModel.selectedPhotoDateFilter != .all,
                    action: {
                        
                    }
                )
                
                if let henId = viewModel.selectedPhotoHenFilter,
                   let hen = viewModel.getHen(by: henId) {
                    FilterChip(
                        title: hen.name,
                        isSelected: true,
                        action: {
                            viewModel.selectedPhotoHenFilter = nil
                        }
                    )
                }
                
                if let tag = viewModel.selectedPhotoTagFilter {
                    FilterChip(
                        title: "#\(tag)",
                        isSelected: true,
                        action: {
                            viewModel.selectedPhotoTagFilter = nil
                        }
                    )
                }
                
                if viewModel.selectedPhotoDateFilter != .all ||
                   viewModel.selectedPhotoHenFilter != nil ||
                   viewModel.selectedPhotoTagFilter != nil {
                    FilterChip(
                        title: "Clear",
                        isSelected: false,
                        action: {
                            viewModel.selectedPhotoDateFilter = .all
                            viewModel.selectedPhotoHenFilter = nil
                            viewModel.selectedPhotoTagFilter = nil
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}

struct PhotoGridView: View {
    let photo: Photo
    let onDelete: () -> Void
    
    var body: some View {
        Group {
            if let localPhotoPath = photo.localPhotoPath {
                if let image = localPhotoPath.loadImageFromDocuments() {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(systemName: "photo")
                        .foregroundColor(.secondary)
                }
            } else {
                Image(systemName: "photo")
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray5))
        .frame(width: 100, height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .onLongPressGesture {
            onDelete()
        }
        .overlay(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: "trash.circle.fill")
                        .foregroundColor(.red)
                        .background(Color.white)
                        .clipShape(Circle())
                        .padding(4)
                }
            }
        )
    }
}

struct FullScreenPhotoView: View {
    let photo: Photo
    let viewModel: HenListViewModel
    @Environment(\.presentationMode) private var presentationMode
    @State private var showingHenDetail = false
    
    var hen: Hen? {
        viewModel.getHen(by: photo.henId)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Group {
                    if let localPhotoPath = photo.localPhotoPath,
                       let image = localPhotoPath.loadImageFromDocuments() {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        Image(systemName: "photo")
                            .font(.system(size: 100))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    if let caption = photo.caption {
                        Text(caption)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    
                    HStack {
                        if let hen = hen {
                            Button(action: { showingHenDetail = true }) {
                                HStack {
                                    Circle()
                                        .fill(hen.breedingStatus.color)
                                        .frame(width: 16, height: 16)
                                    
                                    Text(hen.name)
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Text(photo.formattedDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if !photo.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(photo.tags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .navigationTitle("Photo")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Share") {
                    
                }
            )
            .sheet(isPresented: $showingHenDetail) {
                if let hen = hen {
                    NavigationView {
                        HenDetailView(hen: hen, viewModel: viewModel)
                    }
                }
            }
        }
    }
}

struct EmptyPhotosView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 80))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Photos")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Add your first photo to start the album")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

struct PhotoFiltersSheetView: View {
    @ObservedObject var viewModel: HenListViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Date Filter")) {
                    Picker("Period", selection: $viewModel.selectedPhotoDateFilter) {
                        ForEach(DateFilter.allCases) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Hen Filter")) {
                    Picker("Hen", selection: $viewModel.selectedPhotoHenFilter) {
                        Text("All hens").tag(nil as UUID?)
                        ForEach(viewModel.hens) { hen in
                            Text(hen.name).tag(hen.id as UUID?)
                        }
                    }
                }
                
                Section(header: Text("Tag Filter")) {
                    Picker("Tag", selection: $viewModel.selectedPhotoTagFilter) {
                        Text("All tags").tag(nil as String?)
                        ForEach(viewModel.allTags, id: \.self) { tag in
                            Text("#\(tag)").tag(tag as String?)
                        }
                    }
                }
                
                Section {
                    Button("Clear All Filters") {
                        viewModel.selectedPhotoDateFilter = .all
                        viewModel.selectedPhotoHenFilter = nil
                        viewModel.selectedPhotoTagFilter = nil
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Photo Filters")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct PhotoAlbumView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoAlbumView(viewModel: HenListViewModel())
    }
}
