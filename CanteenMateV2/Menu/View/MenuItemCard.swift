//
//  MenuItemCard.swift
//  CanteenMateV2
//
//  Created by Ahmed Nizhan Haikal on 16/05/25.
//

import Foundation
import SwiftUI

struct MenuItemCard: View {
    let item: Menu
    
    var body: some View {
        VStack(spacing: 4) {
            Text(item.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Rp\(formatToIdr(item.price))")
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .overlay(RoundedRectangle(cornerRadius: 8)
            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
        )
    }
}

#Preview {
    MenuItemCard(item: Menu(name: "Bakso", price: 10000))
}
