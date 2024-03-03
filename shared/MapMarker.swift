import SwiftUI
import MapKit

struct MapMarker: View {
    
    var station : GBFSStation
    var mapRegion : MKCoordinateRegion?
    
    func markerColor(count: Int) -> Color {
        switch count {
        case 0:
            return Color.red
        case 1..<3:
            return Color.orange
        case 3..<5:
            return Color.yellow
        default:
            return Color.green
        }
    }
    
    func closeUp(mapRegion: MKCoordinateRegion?) -> Bool {
        
        let span = Double(mapRegion?.span.longitudeDelta ?? 20)
        
        if span > 0.01 {
            return false
        }
        else {
            return true
        }
        
    }
    
    var body: some View {
        ZStack (alignment: .center) {
            if closeUp(mapRegion: mapRegion) {
                Circle()
                    .fill(markerColor(count: station.bikesAvailable))
                    .frame(width: 25)
                Text("\(station.bikesAvailable)")
                    .padding(2)
                    .fontWeight(.semibold)
            }
            else {
                Circle()
                    .fill(markerColor(count: station.bikesAvailable))
                    .frame(width: 8)
            }
        }
    }
}

