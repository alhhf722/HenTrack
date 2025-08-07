import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = HenListViewModel()
    
    var body: some View {
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
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}