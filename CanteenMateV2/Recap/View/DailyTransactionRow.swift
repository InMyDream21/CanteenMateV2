//
//  DailyTransactionRow.swift
//  CanteenMateV2
//
//  Created by Ahmed Nizhan Haikal on 16/05/25.
//

import Foundation
import SwiftUI

struct DailyTransactionRow: View {
    var transaction: Transaction

    var body: some View {
        HStack {
            Text(transaction.date, style: .time)
                .bold()
                .padding(.vertical)
            Text(transaction.name)
                .font(.headline)
                .padding(.vertical)
                .padding(.trailing)
            Text("Quantity: \(transaction.count)\(transaction.desc?.isEmpty == false ? " • \(transaction.desc!)" : "")")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.vertical)
            Spacer()
            Text("Rp\(formatToIdr(transaction.amount))")
                .font(.body)
                .foregroundColor(transaction.type == .income ? .green : .red)
                .padding(.vertical)
        }
    }
}

#Preview {
    DailyTransactionRow(transaction: Transaction(name: "Test", date: Date(), amount: 100000, type: .income, count: 2, desc: "Jadi ini deskripsi ygy"))
}
