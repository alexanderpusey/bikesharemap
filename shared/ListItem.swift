import SwiftUI

struct ListItem: View {
    
    var system : GBFSSystem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2){
                Text(system.name)
                    .font(.headline)
                Text((system.location))
                    .font(.subheadline)
            }
            Spacer()
        }
        .contentShape(Rectangle())
    }
}
