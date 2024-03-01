import SwiftUI
import MapKit

struct DistanceIndicator: View {
    
    var userLocation: Binding<CLLocation>
    var stations: [GBFSStation]
    
    var body: some View {
        Text("location indicator")
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


////            TODO: only show upon load, only show if distance is > super nearby, frame map to show the distance, or lack of
//            if let userLocation = locationService.location,
//               viewModel.distanceIndicatorOn,
//               let closestStation = closestStation(userLocation: locationService.location, stations: viewModel.stations) {
////                TODO: dotted, text for minutes
//                MapPolyline (
//                    coordinates: [CLLocationCoordinate2D(latitude: closestStation.lat, longitude: closestStation.lon), CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
//                            ],
//                        contourStyle: .straight
//                )
//                .mapOverlayLevel(level: .aboveRoads)
//                .stroke(Color.seeThroughWhite, style: StrokeStyle(lineWidth: 4, dash: [6]))
//                
//            } else {
//                EmptyMapContent()
//            }
