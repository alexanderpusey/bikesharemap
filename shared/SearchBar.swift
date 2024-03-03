import SwiftUI

struct SearchBar: View {
    
    @Binding var searchText : String
    
    var body: some View {
        
            if searchText.isEmpty {
                #if os(watchOS)
                TextFieldLink(prompt: Text("Search"), label: {
                    HStack(alignment: .center, spacing: 1.4) {
                        Image(systemName: "magnifyingglass")
                            .imageScale(.small)
                            .foregroundStyle(Color("TitleColor"))
                        Text("Systems")
                            .foregroundStyle(Color("TitleColor"))
                    }
                    .fontWeight(.bold)
                    .opacity(0.7)
                }, onSubmit: { text in
                    searchText = text
                })
                .buttonStyle(.borderless)
                .allowsHitTesting(true)
                .autocorrectionDisabled(true)
                #else
                TextField("Search", text: $searchText)
                    .autocorrectionDisabled(true)
                #endif
            }
            if !searchText.isEmpty {
                HStack(alignment: .center, spacing: 1.4) {
                    Image(systemName: "xmark")
                        .imageScale(.small)
                    Text(searchText)
                }
                .opacity(0.7)
                .fontWeight(.bold)
                .onTapGesture {
                    searchText = ""
                }
                
            }
    }
}
