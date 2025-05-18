//
//  DetailColumn.swift
//  CanteenMateV2
//
//  Created by Ahmed Nizhan Haikal on 14/05/25.
//

import Foundation
import SwiftUI

struct DetailColumn: View {
    @Binding var selection: Panel?
    var body: some View {
        switch selection ?? .recap {
        case .recap:
            RecapPage()
        case .menu:
            MenuPage()
        }
    }
}
    
struct DetailColumn_Preview: PreviewProvider {
    struct Preview: View {
        @State private var selection: Panel? = .recap
        var body: some View {
            DetailColumn(selection: $selection)
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
