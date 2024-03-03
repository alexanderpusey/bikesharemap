import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    
    var system : GBFSSystem
    @Environment(\.modelContext) private var modelContext
    @Environment(DataManager.self) private var dataManager
    @State var stations: [GBFSStation] = []
    @State var showingUserLocationButton = false
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
            .toolbar {
                
                ToolbarItemGroup(placement: .bottomBar) {
                    if showingUserLocationButton {
                        Image(systemName: "location.circle.fill")
                            .font(.system(size: 14))
                            .opacity(0.7)
                            .offset(x: 1, y: 4.5)
                            .onTapGesture {
                                Task {
                                    mapPosition = MapCameraPosition.userLocation(followsHeading: true, fallback: MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: system.center_lat, longitude: system.center_lon), latitudinalMeters: 2000, longitudinalMeters: 2000)))
                                }
                            }
                    }
                    Spacer()
                    ZStack {
                        switch dataManager.stationsLoadingState {
                        case .loading:
                                ProgressView()
                                .scaleEffect(0.8)
                        case .idle:
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .font(.system(size: 14))
                                .opacity(0.7)
                                .onTapGesture {
                                    Task {
                                        await dataManager.refreshStations(system: system)
                                    }
                                }
                        case .failed:
                            Image(systemName: "network.slash")
                                .foregroundStyle(.red)
                                .font(.system(size: 14))
                        }
                    }
                    .offset(x: -1, y : 4.5)
                }
                
            }
            .task {
                mapPosition = MapCameraPosition.userLocation(followsHeading: true, fallback: MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: system.center_lat, longitude: system.center_lon), latitudinalMeters: 2000, longitudinalMeters: 2000)))
                
                let refreshedStations = await dataManager.refreshStations(system: system)
                
                if refreshedStations.count > 500 {
                    mapBounds = MapCameraBounds(minimumDistance: 200, maximumDistance: 7000)
                }
            }
            .onMapCameraChange(frequency: .continuous) { mapCameraUpdateContext in
                mapRegion = mapCameraUpdateContext.region
            }
            .onChange(of: locationService.location) {
//              if user's location is far away from system center, move the camera to system center
                if let userLocation = locationService.location {
                    let userCLLocation = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
                    let distanceFrom = userCLLocation.distance(from: CLLocation(latitude: system.center_lat, longitude: system.center_lon))
                    let maxDistance: CLLocationDistance = 45 * 1609.34
                    if distanceFrom > maxDistance {
                        mapPosition = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: system.center_lat, longitude: system.center_lon), latitudinalMeters: 2000, longitudinalMeters: 2000))
                    }
                }
                
            }
            .onChange(of: mapPosition) {
//              show user location centering button if within distance
                if let userLocation = locationService.location, let region = mapRegion {
                
                    let userCLLocation = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
                    let distanceFrom = userCLLocation.distance(from: CLLocation(latitude: region.center.latitude, longitude: region.center.longitude))
                    let maxDistance: CLLocationDistance = 45 * 1609.34
//                  if map isn't on user location and isn't super far away either
                    if distanceFrom > 0.01 && distanceFrom < maxDistance {
                        showingUserLocationButton = true
                    }
                    else {
                        showingUserLocationButton = false
                    }
                }
                else {
                    showingUserLocationButton = false
                }
            }

    }
    
}

//used for optimizing which stations are rendered on the map
//filters stations by whether their distance from map region center exceeds a value multiplied by mapregionLength
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
