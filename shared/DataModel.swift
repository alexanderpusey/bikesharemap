import Foundation
import SwiftData

@Model
class GBFSSystem: Identifiable {
    
    @Attribute(.unique) var system_id : Int
    var name : String
    var location : String
    var station_information_url : String
    var station_status_url : String
    var center_lat : Double
    var center_lon : Double
    
    init(name: String, location: String, system_id: Int, station_information_url: String, station_status_url: String, center_lat: Double, center_lon: Double) {
        self.name = name
        self.location = location
        self.system_id = system_id
        self.station_information_url = station_information_url
        self.station_status_url = station_status_url
        self.center_lat = center_lat
        self.center_lon = center_lon
    }
    
}

class GBFSStation: Identifiable {
    var id: String
    var lon : Double
    var lat : Double
    var name: String
    var docksAvailable : Int = 0
    var bikesAvailable : Int = 0

    init(id: String, lon: Double, lat: Double, name: String, docksAvailable: Int, bikesAvailable: Int) {
        self.id = id
        self.lon = lon
        self.lat = lat
        self.name = name
        self.docksAvailable = docksAvailable
        self.bikesAvailable = bikesAvailable
    }
    
}

struct JSONSystem: Decodable {
    let name: String
    let location: String
    let system_id: Int
    let url: String
    let station_information_url: String
    let station_status_url: String
    let center_lat: Double
    let center_lon: Double
}


struct JSONStationInformation : Decodable {
    var ttl : Int
    var data : StationInformationData
    var last_updated : Int
    
    struct StationInformationData : Decodable {
        var stations : [StationInformation]
    }
    
    struct StationInformation : Codable {
        var lon : Double
        var lat : Double
        var name: String
        var station_id : String
    }
}

struct JSONStationStatus : Decodable {
    var ttl : Int
    var data : StationStatusData
    var last_updated : Int
    
    struct StationStatusData : Decodable {
        var stations : [StationStatus]
    }
    
    struct StationStatus : Codable {
        var num_docks_available : Int
        var num_bikes_available : Int
        var station_id : String
    }
}

