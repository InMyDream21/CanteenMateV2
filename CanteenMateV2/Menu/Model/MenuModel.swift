//
//  MenuModel.swift
//  CanteenMateV2
//
//  Created by Ahmed Nizhan Haikal on 09/05/25.
//

import Foundation
import SwiftData

@Model
class Menu: Identifiable {
    var id = UUID()
    var name: String
    var price: Int
    
    init(id: UUID = UUID(), name: String, price: Int) {
        self.id = id
        self.name = name
        self.price = price
    }
}
