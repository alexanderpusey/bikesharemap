import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    
    var system : GBFSSystem
    @Environment(\.modelContext) private var modelContext
    @Environment(DataManager.self) private var dataManager
    @State var stations: [GBFSStation] = []
    @ObservedObject var locationService = LocationService()
    @State var mapPosition = MapCameraPosition.automatic
    @State var mapRegion : MKCoordinateRegion? = nil
    @State var mapBounds : MapCameraBounds? = MapCameraBounds(minimumDistance: 200)
    
    var body: some View {
            
        Map (position: $mapPosition, bounds: mapBounds) {
                
                ForEach(filterStations(stations: dataManager.stations, mapRegion: mapRegion)) { station in
                    
                    Annotation(station.name, coordinate: CLLocationCoordinate2D(latitude: station.lat, longitude: station.lon)) {
                        MapMarker(station: station, mapPosition: mapPosition)
                    }
                                
                }
                .annotationTitles(.hidden)
                
//                DistanceIndicator(userLocation: locationService.$location, stations: stations)
                
                UserAnnotation(anchor: .center)
                    .mapOverlayLevel(level: .aboveLabels)
            }
            .mapStyle(.standard(elevation: .realistic, emphasis: .muted, pointsOfInterest: .excludingAll, showsTraffic: false))
            .mapControls {
                
            }
            .mapControls {
                #if os(watchOS)
                MapLocationCompass()
                #else
                MapUserLocationButton()
                #endif
            }
            .ignoresSafeArea()
            .task {
                
                mapPosition = MapCameraPosition.userLocation(followsHeading: true, fallback: MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: system.center_lat, longitude: system.center_lon), latitudinalMeters: 2000, longitudinalMeters: 2000)))
                
                let refreshedSystems = await dataManager.refreshStations(system: system)
                
                if refreshedSystems.count > 1000 {
                    mapBounds = MapCameraBounds(minimumDistance: 200, maximumDistance: 4000)
                }
            }
            .onMapCameraChange(frequency: .continuous) { mapCameraUpdateContext in
                mapRegion = mapCameraUpdateContext.region
            }

    }
    
}

func filterStations(stations: [GBFSStation], mapRegion: MKCoordinateRegion?) -> [GBFSStation] {
    if stations.count > 300 {

        if let region = mapRegion {
            let center = region.center
            let length = region.span
            
            let filteredStations = stations.filter { station in
                    let stationLocation = CLLocation(latitude: station.lat, longitude: station.lon)
                    let distance = stationLocation.distance(from: CLLocation(latitude: center.latitude, longitude: center.longitude))
                return distance <= (length.longitudeDelta * 90000)
                }
            
            return filteredStations

        }
        return stations
    }
    else {
        return stations
    }
}
