//
//  PredefinedMenuCard.swift
//  CanteenMateV2
//
//  Created by Ahmed Nizhan Haikal on 16/05/25.
//

import Foundation
import SwiftUI
import SwiftData

struct PredefinedMenuCard: View {
    let item: Menu
    let quantity: Int
    let onTap: () -> Void
    let onAdd: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            VStack {
                Text(item.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Rp\(formatToIdr(item.price))")
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
            
            HStack {
                Button(action: {
                    onRemove()
                }) {
                    Image(systemName: "minus")
                        .foregroundColor(.red)
                }
                
                Text("\(quantity)")
                    .font(.title2)
                    .frame(minWidth: 40)
                
                Button(action: {
                    onAdd()
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
        .padding()
        .frame(maxWidth: .infinity)
        .overlay(RoundedRectangle(cornerRadius: 8)
            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
        )
    }
}
