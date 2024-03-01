import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    
    var system : GBFSSystem
    @Environment(\.modelContext) private var modelContext
    @Environment(DataManager.self) private var dataManager
    @State var stations: [GBFSStation] = []
    @ObservedObject var locationService = LocationService()
    @State private var mapPosition = MapCameraPosition.userLocation(followsHeading: true, fallback: MapCameraPosition.automatic)
    var mappingService = MappingService()
    
    var body: some View {
            
            Map (position: $mapPosition) {
                
                ForEach(dataManager.stations) { station in
                    
                    Annotation(station.name, coordinate: CLLocationCoordinate2D(latitude: station.lat, longitude: station.lon)) {
                        MapMarker(station: station, mapPosition: mapPosition)
                    }
                                
                }
                .annotationTitles(.hidden)
                
                UserAnnotation(anchor: .center)
                    .mapOverlayLevel(level: .aboveLabels)
            }
            .mapStyle(.standard(elevation: .realistic, emphasis: .muted, pointsOfInterest: .excludingAll, showsTraffic: false))
            .mapControls {}
            .ignoresSafeArea()
            .task {
                await dataManager.refreshStations(system: system)
            }

    }
    
}

