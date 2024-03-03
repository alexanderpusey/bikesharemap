import Foundation
import CoreLocation

class LocationService : NSObject, CLLocationManagerDelegate, ObservableObject {
    var locationManager = CLLocationManager()
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 50
        locationManager.activityType = CLActivityType.fitness
        locationManager.allowsBackgroundLocationUpdates = false
    }
    
    func isHeadingAvailale() -> Bool {
        return CLLocationManager.headingAvailable()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            enableLocationFeatures()
            break
            
        case .restricted, .denied:
            disableLocationFeatures()
            break
            
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            break
            
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newLocation = locations.first {
            location = newLocation
        }
    }
    
    func enableLocationFeatures() {
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func disableLocationFeatures() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
    
}

