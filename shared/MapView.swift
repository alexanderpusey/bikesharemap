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
    @State var region : MKCoordinateRegion? = nil
    
    var body: some View {
            
            Map (position: $mapPosition) {
                
                ForEach(filterStations(stations: dataManager.stations, mapRegion: region)) { station in
                    
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
            .mapControls {}
            .ignoresSafeArea()
            .task {
                mapPosition = MapCameraPosition.userLocation(followsHeading: true, fallback: MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: system.center_lat, longitude: system.center_lon), latitudinalMeters: 2000, longitudinalMeters: 2000)))
                await dataManager.refreshStations(system: system)
            }
            .onMapCameraChange(frequency: .onEnd) { mapCameraUpdateContext in
                region = mapCameraUpdateContext.region
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
                return distance <= (length.longitudeDelta * 100000)
                }
            
            return filteredStations

        }
        return stations
    }
    else {
        return stations
    }
}

func filterStationsByLocation(userLocation: CLLocation?, stations: [GBFSStation]) -> [GBFSStation] {
    
    print("filtering by location \(userLocation.debugDescription)...")
    
    guard let location = userLocation else {
        return stations
    }
    
    let maxDistance: CLLocationDistance = 0.5 * 1609.34
    
    let filteredStations = stations.filter { station in
            let stationLocation = CLLocation(latitude: station.lat, longitude: station.lon)
            let distance = location.distance(from: stationLocation)
            return distance <= maxDistance
        }

    print("filtered!")
    return filteredStations
}

