//
//  CanteenMateV2App.swift
//  CanteenMateV2
//
//  Created by Ahmed Nizhan Haikal on 09/05/25.
//

import SwiftUI
import SwiftData
import Foundation

@main
struct CanteenMateV2App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Menu.self, Transaction.self])
    }
}
