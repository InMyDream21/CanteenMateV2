//
//  Panel.swift
//  CanteenMateV2
//
//  Created by Ahmed Nizhan Haikal on 14/05/25.
//

import Foundation
import SwiftUI

enum Panel: Hashable {
    case recap
    case menu
}

struct Sidebar: View {
    @Binding var selection: Panel?
    var body: some View {
        List(selection: $selection) {
            NavigationLink(value: Panel.recap) {
                Label("Recap", systemImage: "chart.bar.horizontal.page")
            }
            
            NavigationLink(value: Panel.menu) {
                Label("Menu", systemImage: "menucard")
            }
        }
        .navigationTitle("Canteen Mate")
    }
}

struct Sidebar_Preview: PreviewProvider {
    struct Preview: View {
        @State private var selection: Panel? = Panel.recap
        var body: some View {
            Sidebar(selection: $selection)
        }
    }
    
    static var previews: some View {
        NavigationSplitView {
            Preview()
        } detail: {
            RecapPage()
        }
    }
}
