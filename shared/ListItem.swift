import SwiftUI

struct ListItem: View {
    
    var system : GBFSSystem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2){
                Text(system.name)
                    .font(.headline)
                Text((system.location))
                    .font(.footnote)
                    .opacity(0.5)
            }
            Spacer()
        }
        .contentShape(Rectangle())
    }
}
