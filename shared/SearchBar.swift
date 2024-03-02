import SwiftUI

struct SearchBar: View {
    
    @Binding var searchText : String
    
    var body: some View {
            if searchText.isEmpty {
                #if os(watchOS)
                TextFieldLink(prompt: Text("Search"), label: {
                    HStack(alignment: .center, spacing: 1.4) {
                        Image(systemName: "magnifyingglass").imageScale(.small)
                        Text("Systems")
                    }
                    .opacity(0.7)
                }, onSubmit: { text in
                    searchText = text
                })
                .fontWeight(.bold)
                .buttonStyle(.borderless)
                .allowsHitTesting(true)
                .disableAutocorrection(true)
                #else
                TextField("", text: $searchText)
                    .disableAutocorrection(true)
                #endif
            }
            if !searchText.isEmpty {
                HStack(spacing: 1.7) {
                    Text(searchText)
                    .opacity(0.3)
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark").imageScale(.small)
                            .opacity(0.7)
                    }
                    .buttonStyle(.borderless)
                }
                
            }
    }
}
