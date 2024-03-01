import SwiftUI

struct SearchBar: View {
    
    @Binding var searchText : String
    
    var body: some View {
        ZStack(alignment: .leading) {
            if searchText.isEmpty {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Systems")
                }
                .opacity(0.3)
                .padding(10)
            }
            TextField("", text: $searchText)
                .disableAutocorrection(true)
                .foregroundStyle(Color.white.opacity(0.5))
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Spacer()
                    Image(systemName: "xmark")
                        .opacity(0.3)
                        .padding(10)
                        .zIndex(2)
                }
                .buttonStyle(.borderless)
            }
        }
    }
}
