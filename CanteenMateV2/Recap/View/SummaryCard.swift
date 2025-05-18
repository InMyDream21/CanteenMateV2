//
//  SummaryCard.swift
//  CanteenMateV2
//
//  Created by Ahmed Nizhan Haikal on 14/05/25.
//

import Foundation
import SwiftUI

struct SummaryCard: View {
    let title: String
    let amount: Int
    let textColor: Color
    let selectedColor: Color
    let imageName: String
    var selected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: imageName)
                    .foregroundColor(selected ? .white : .primary)
                Text(title)
                    .font(.title3)
                    .foregroundColor(selected ? .white : .primary)
            }
            Text("Rp\(title == "Net Total" && amount < 0 ? "-\(formattedAmount)" : formattedAmount)")
                .font(.title2)
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .allowsTightening(true)
                .foregroundColor(selected ? .white : textColor)
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .padding()
        .overlay(RoundedRectangle(cornerRadius: 16)
            .stroke(Color(.systemGray2), lineWidth: 1))
        .contentShape(Rectangle())
        .background(selected ? selectedColor : .clear)
        .cornerRadius(16)
        
    }

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return formatter.string(from: NSNumber(value: abs(amount))) ?? "\(abs(amount))"
    }
}

struct SummaryCardPreview: PreviewProvider {
    struct Preview: View {
        @State private var selected: Bool = false
        var body: some View {
            HStack{
                SummaryCard(
                    title: "Expense",
                    amount: 100000,
                    textColor: .red,
                    selectedColor: .red,
                    imageName: "chart.line.uptrend.xyaxis",
                    selected: selected
                )
                
                SummaryCard(
                    title: "Expense",
                    amount: 100000,
                    textColor: .red,
                    selectedColor: .red,
                    imageName: "chart.line.uptrend.xyaxis",
                    selected: selected
                )
                SummaryCard(
                    title: "Expense",
                    amount: 100000,
                    textColor: .red,
                    selectedColor: .red,
                    imageName: "chart.line.uptrend.xyaxis",
                    selected: selected
                )
            }
        }
    }
        
    static var previews: some View {
        Preview()
    }
}
