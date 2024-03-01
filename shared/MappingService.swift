import Foundation
import MapKit
import SwiftUI

class MappingService {

    func filterStationsByMapCenter(mapCenter: MKMapRect?, stations: [GBFSStation]) -> [GBFSStation] {
        
        if let mapCenter = mapCenter {
            print(mapCenter.size)
        }
        return stations
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
}

