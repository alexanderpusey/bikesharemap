import SwiftUI

struct SearchBar: View {
    
    @Binding var searchText : String
    
    var body: some View {
            if searchText.isEmpty {
                #if os(watchOS)
                TextFieldLink(prompt: Text("Search"), label: {
                    HStack(alignment: .firstTextBaseline, spacing: 1.4) {
                        Image(systemName: "magnifyingglass").imageScale(.small)
                        Text("Systems")
                    }
                    .opacity(0.4)
                }, onSubmit: { text in
                    searchText = text
                })
                .buttonStyle(.borderless)
                .allowsHitTesting(true)
                .disableAutocorrection(true)
                #else
                TextField("", text: $searchText)
                    .disableAutocorrection(true)
                #endif
            }
            if !searchText.isEmpty {
                HStack(alignment: .firstTextBaseline, spacing: 1.4) {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark").imageScale(.small)
                            .opacity(0.4)
                    }
                    .buttonStyle(.borderless)
                    Text(searchText)
                    .opacity(0.3)
                }
                
            }
    }
}
