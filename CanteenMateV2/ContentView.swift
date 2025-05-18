import SwiftUI

enum Page: String, CaseIterable, Identifiable {
    case recap = "Recap"
    case menu = "Menu"
    
    var id: String { self.rawValue }
}

struct ContentView: View {
    @State private var selection: Panel? = .recap
    
    var body: some View {
        NavigationSplitView {
            Sidebar(selection: $selection)
        } detail: {
            NavigationStack() {
                DetailColumn(selection: $selection)
            }
        }
    }
}

#Preview {
    ContentView()
}
