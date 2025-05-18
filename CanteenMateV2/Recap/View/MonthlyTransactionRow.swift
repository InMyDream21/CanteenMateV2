//
//  MonthlyTransactionRow.swift
//  CanteenMateV2
//
//  Created by Ahmed Nizhan Haikal on 16/05/25.
//

import Foundation
import SwiftUI

struct MonthlyTransactionRow: View {
    var transaction: GroupedTransaction

    var body: some View {
            HStack {
                Text(transaction.date, format: .dateTime.day().month())
                    .padding()
                
                Spacer()

                Text("Rp\(formatToIdr(transaction.totalAmount))")
                    .foregroundColor(transaction.totalAmount > 0 ? .green : .red)
            }
            .padding(.vertical, 6)
    }
}

#Preview {
    MonthlyTransactionRow(transaction: GroupedTransaction(date: Date(), totalAmount: 100000))
}
