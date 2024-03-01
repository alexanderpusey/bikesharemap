import SwiftUI
import MapKit

struct MapMarker: View {
    
    var station : GBFSStation
    var mapPosition : MapCameraPosition
    
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
    
    var body: some View {
        Text("\(station.bikesAvailable)")
            .foregroundColor(.white) // Set text color to white for better visibility
            .font(.system(size: 20)) // Adjust font size as needed
            .padding(6) // Increase padding to provide space around the text
            .background(
                Circle()
                    .fill(markerColor(count: station.bikesAvailable))
                    .frame(width: 35, height: 35) // Set the width and height to make the circle larger
            )
    }
}

