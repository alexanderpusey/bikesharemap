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

                List(filterSystems(systems: systems, searchText: searchText, userLocation: locationService.location), selection: $selectedSystem) { system in
                    VStack(alignment: .leading, spacing: 2){
                        Text(system.name)
                        Text((system.location))
                            .font(.subheadline)
                    }
                    .onTapGesture {
                        selectedSystemID = system.system_id
                        selectedSystem = system
                    }
                }
            }
            .onAppear {
                
                if let storedSystem = systems.first(where: {$0.system_id == selectedSystemID}) {
                    selectedSystem = storedSystem
                }
                
            }
            .task { await dataManager.refreshSystems(modelContext: modelContext)}
            
        } detail: {
            if selectedSystem != nil {
                MapView(system: selectedSystem!)
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItemGroup(placement: .topBarLeading) {
                            HStack {
                                Text(selectedSystem!.name)
                                Spacer()
                            }
                            .onTapGesture {
                                dataManager.deleteStations()
                                selectedSystemID = nil
                                selectedSystem = nil
                            }
                        }
                        ToolbarItemGroup(placement: .destructiveAction) {
                            ZStack {
                                if dataManager.stationsLoadingState == .loading {
                                    ProgressView()
                                }
                                else {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                        .opacity(0.7)
                                        .onTapGesture {
                                            Task {
                                                await dataManager.refreshStations(system: selectedSystem!)
                                            }
                                        }
                                }
                            }
                            
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

