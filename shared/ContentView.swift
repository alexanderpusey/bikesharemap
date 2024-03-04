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
                
                #if os(watchOS)
                SearchBar(searchText: $searchText)
                    .padding(2)
                #endif

                List(filterSystems(systems: systems, searchText: searchText, userLocation: locationService.location), selection: $selectedSystem) { system in
                    
                    ListItem(system: system)
                        .onTapGesture {
                            selectedSystem = system
                            selectedSystemID = system.system_id
                        }
                    
                }
                .listStyle(.plain)
                #if os(iOS)
                .padding()
                .searchable(text: $searchText, placement: .navigationBarDrawer)
                .autocorrectionDisabled()
                #endif
                
            }
            .onAppear {
                
                if let storedSystem = systems.first(where: {$0.system_id == selectedSystemID}) {
                    selectedSystem = storedSystem
                }
                
            }
            .task { await dataManager.refreshSystems(modelContext: modelContext) }
            .padding(.top, -17)
            
        } detail: {
            
            if selectedSystem != nil {
                
                MapView(system: selectedSystem!)
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        
                        ToolbarItemGroup(placement: .topBarLeading) {
                            HStack (spacing: 2.3) {
                                Image(systemName: "list.bullet")
                                    .font(.system(size: 14, weight: .semibold))
                                Text(selectedSystem!.name)
                                    .font(.system(size: 14, weight: .semibold))
                                    .lineLimit(1)
                            }
                            .opacity(0.9)
                            .onTapGesture {
                                dataManager.deleteStations()
                                selectedSystemID = nil
                                selectedSystem = nil
                            }
                            .contentShape(.rect)
                            Spacer()
                        }
                        
                        ToolbarItem(placement: .destructiveAction) {
                            Text("0")
                                .opacity(0)
                        }
                        
                    }
                    .toolbarBackground(.hidden, for: .automatic)
            }
            
            else { EmptyView() }
            
        }
        .task {
            locationService.enableLocationFeatures()
        }
    }
    
}

func filterSystems(systems: [GBFSSystem], searchText: String, userLocation: CLLocation?) -> [GBFSSystem] {
    
    if !searchText.isEmpty {
        return systems.filter { system in
            system.name.lowercased().contains(searchText.lowercased()) ||
            system.location.lowercased().contains(searchText.lowercased())
        }
    }
    
    guard let userLocation = userLocation else {
        return systems
    }
    
    let maxDistance: CLLocationDistance = 40 * 1609.34

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
