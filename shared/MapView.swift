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
                    MapMarker(station: station, mapRegion: mapRegion)
                }
                            
            }
            .annotationTitles(.hidden)
    
            UserAnnotation(anchor: .center)
                .mapOverlayLevel(level: .aboveLabels)
            
            }
            .mapStyle(.standard(elevation: .realistic, emphasis: .muted, pointsOfInterest: .excludingAll, showsTraffic: false))
            .mapControlVisibility(.hidden)
            .ignoresSafeArea()
            .task {
                
                mapPosition = MapCameraPosition.userLocation(followsHeading: true, fallback: MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: system.center_lat, longitude: system.center_lon), latitudinalMeters: 2000, longitudinalMeters: 2000)))
                
                let refreshedSystems = await dataManager.refreshStations(system: system)
                
                if refreshedSystems.count > 300 {
                    mapBounds = MapCameraBounds(minimumDistance: 200, maximumDistance: 6000)
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
                return distance <= (length.longitudeDelta * 80000)
                }
            
            return filteredStations

        }
        return stations
    }
    else {
        return stations
    }
}

func closestStation(userLocation: CLLocation?, stations: [GBFSStation]) -> GBFSStation? {
    guard let userLocation = userLocation else {
        return nil
    }

    var closestStation: GBFSStation?
    var minDistance: CLLocationDistance = Double.greatestFiniteMagnitude

    for station in stations {
        let stationLocation = CLLocation(latitude: station.lat, longitude: station.lon)
        let distance = userLocation.distance(from: stationLocation)

        if distance < minDistance {
            minDistance = distance
            closestStation = station
        }
    }

    return closestStation
}
