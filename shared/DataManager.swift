import Foundation
import SwiftUI
import SwiftData
import CoreLocation

@Observable
class DataManager {
    
    var stationsLoadingState : LoadState = .idle
    var stations : [GBFSStation] = []
    
    enum LoadState {
            case idle
            case loading
            case failed
        }
    
    enum DataError: Error {
        case fetchError
        case decodingError
    }
    
    func fetchSystems() async throws -> [JSONSystem] {
        
        let url = URL(string: "http://localhost:3000/systems")!
        
        print("fetching systems...")
        let session = URLSession.shared
        guard let (data, response) = try? await session.data(from: url),
              let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else {
            print("failed to fetch")
            throw DataError.fetchError
        }
        
        print("decoding systems...")
        do {
            let jsonDecoder = JSONDecoder()
            return try jsonDecoder.decode([JSONSystem].self, from: data)
        } catch let error {
            print(error)
            throw DataError.decodingError
        }
        
    }
    
    @MainActor
    func refreshSystems(modelContext: ModelContext) async {
        
        do {
            let JSONSystems = try await fetchSystems()
            
            print("inserting systems into storage...")
            for feature in JSONSystems {
                let system = GBFSSystem(name: feature.name, location: feature.location, system_id: feature.system_id, station_information_url: feature.station_information_url, station_status_url: feature.station_status_url, center_lat: feature.center_lat, center_lon: feature.center_lon)
                modelContext.insert(system)
            }

        } catch let error {
            print("\(error.localizedDescription)")
        }
    }
    
    func fetchStations(system: GBFSSystem) async throws -> (info: JSONStationInformation, status: JSONStationStatus) {
        
        let infoURL = URL(string: system.station_information_url)!
        let statusURL = URL(string: system.station_status_url)!
        
//        fetch station information data
        print("fetching station information data...")
        guard let (infoData, response) = try? await URLSession.shared.data(from: infoURL),
              let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else {
            stationsLoadingState = .failed
            print("Failed to fetch station information data")
            throw DataError.fetchError
        }
        
//        fetch station status data
        print("fetching station status data...")
        guard let (statusData, response) = try? await URLSession.shared.data(from: statusURL),
              let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else {
            stationsLoadingState = .failed
            print("Failed to fetch station status data")
            throw DataError.fetchError
        }

//        parse and return JSON
        do {
            print("decoding station jsons...")
            let stationInformation = try JSONDecoder().decode(JSONStationInformation.self, from: infoData)
            let stationStatus = try JSONDecoder().decode(JSONStationStatus.self, from: statusData)
            
            return (stationInformation, stationStatus)
            
        } catch {
            stationsLoadingState = .failed
            print("Failed to decode JSON. Error: \(error)")
            throw DataError.decodingError
        }
        
    }
    
    @MainActor
    func refreshStations(system: GBFSSystem) async {
        
        do {
            
            stationsLoadingState = .loading
            
            let fetchedstations = try await fetchStations(system: system)
            var mergedStations : [GBFSStation] = []
            
            print("combining station json and inserting into storage...")
            for station in fetchedstations.info.data.stations {
                
                if let status = fetchedstations.status.data.stations.first(where: {$0.station_id == station.station_id}) {
                    let stationCombined = GBFSStation(id: station.station_id, lon: station.lon, lat: station.lat, name: station.name, docksAvailable: status.num_docks_available, bikesAvailable: status.num_bikes_available)
                    mergedStations.append(stationCombined)
                    
                }
                else {
                    stationsLoadingState = .failed
                    let stationNoStatus = GBFSStation(id: station.station_id, lon: station.lon, lat: station.lat, name: station.name, docksAvailable: 0, bikesAvailable: 0)
                    mergedStations.append(stationNoStatus)
                }
                
            }
            
            stations = mergedStations
            stationsLoadingState = .idle
            

        } catch let error {
            stationsLoadingState = .failed
            print("\(error.localizedDescription)")
        }
    }
    
    func deleteStations() {
        stations = []
    }
    
    func deleteSystems(modelContext: ModelContext) {
        print("deleting stored systems...")
        do {
            try modelContext.delete(model: GBFSSystem.self)
        }
        catch {
            print("failed to delete system data")
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
        
        let maxDistance: CLLocationDistance = 30 * 1609.34

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


}

