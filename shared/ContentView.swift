import SwiftUI
import SwiftData

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
            
            VStack {
                
                SearchBar(searchText: $searchText)

                List(dataManager.filterSystems(systems: systems, searchText: searchText, userLocation: locationService.location), selection: $selectedSystem) { system in
                    Text(system.name)
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
            .task {
                await dataManager.refreshSystems(modelContext: modelContext)
            }
            
        } detail: {
            if selectedSystem != nil {
                MapView(system: selectedSystem!)
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItemGroup(placement: .topBarLeading) {
                            HStack {
                                Text(selectedSystem!.name)
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

