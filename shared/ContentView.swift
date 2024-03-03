import SwiftUI
import SwiftData
import MapKit

struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(DataManager.self) private var dataManager
    @ObservedObject var locationService = LocationService()
    
    @State var selectedSystem: GBFSSystem? = nil
    @State var searchText: String = ""
    
    @Query(sort: \GBFSSystem.name) var systems: [GBFSSystem]
    @AppStorage("selectedSystemID") var selectedSystemID: Int?
    
    var body: some View {
        
        NavigationSplitView {
            
            VStack (alignment: .leading){
                
                SearchBar(searchText: $searchText)
                    .padding(2)

                List(filterSystems(systems: systems, searchText: searchText, userLocation: locationService.location), selection: $selectedSystem) { system in
                    ListItem(system: system)
                    .onTapGesture {
                        selectedSystemID = system.system_id
                        selectedSystem = system
                    }
                }
                #if os(watchOS)
                .listStyle(.plain)
                #else
                .listStyle(.automatic)
                #endif
            }
            .padding(.top, -17)
            .onAppear {
                
                if let storedSystem = systems.first(where: {$0.system_id == selectedSystemID}) {
                    selectedSystem = storedSystem
                }
                
            }
            .task { await dataManager.refreshSystems(modelContext: modelContext)}
            
        } detail: {
            if selectedSystem != nil {
                MapView(system: selectedSystem!)
                    .padding()
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItemGroup(placement: .topBarLeading) {
                            HStack {
                                HStack (spacing: 2.3) {
                                    Image(systemName: "list.bullet")
                                        .font(.system(size: 13))
                                    Text(selectedSystem!.name)
                                        .fontWeight(.medium)
                                        .font(.system(size: 13))
                                        .onTapGesture {
                                            dataManager.deleteStations()
                                            selectedSystemID = nil
                                            selectedSystem = nil
                                        }
                                }
                                .padding(5)
                                Spacer()
                            }
                            .frame(width: 130)
                        }
                        ToolbarItemGroup(placement: .bottomBar) {
                            Spacer()
                            HStack {
                                HStack {
                                    switch dataManager.stationsLoadingState {
                                    case .loading:
                                            ProgressView()
                                    case .idle:
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                            .font(.system(size: 13))
                                            .opacity(0.7)
                                            .onTapGesture {
                                                Task {
                                                    await dataManager.refreshStations(system: selectedSystem!)
                                                }
                                            }
                                    case .failed:
                                        Image(systemName: "network.slash")
                                            .foregroundStyle(.red)
                                            .font(.system(size: 13))
                                    }
                                }
                            }
                        }
                        ToolbarItem(placement: .topBarLeading) {
                            Text("FILLLEEEERRRR")
                                .opacity(0)
                        }
                        ToolbarItem(placement: .destructiveAction) {
                            Text("FILLLEEEERRRR")
                                .opacity(0)
                        }
                    }
            } else {
                EmptyView()
            }
        }
        .task {
            locationService.enableLocationFeatures()
        }
    }
    
}

func filterSystems(systems: [GBFSSystem], searchText: String, userLocation: CLLocation?) -> [GBFSSystem] {
    
    if !searchText.isEmpty {
        return systems.filter { system in
            system.name.lowercased().contains(searchText.lowercased())
        }
    }
    
    guard let userLocation = userLocation else {
        return systems
    }
    
    let maxDistance: CLLocationDistance = 45 * 1609.34

    var systemsWithinDistance: [GBFSSystem] = []

    for system in systems {
        let systemLocation = CLLocation(latitude: system.center_lat, longitude: system.center_lon)
        let distance = userLocation.distance(from: systemLocation)

        if distance <= maxDistance {
            systemsWithinDistance.append(system)
        }
    }

    return systemsWithinDistance
}

