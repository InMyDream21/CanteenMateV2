//
//  AddTransactionView.swift
//  CanteenMateV2
//
//  Created by Ahmed Nizhan Haikal on 09/05/25.
//

import Foundation
import SwiftUI

struct AddTransactionView: View {
    let category: TransactionType
    var body: some View {
        if category == .income {
            AddIncomeView()
        } else {
            AddExpenseView()
        }
    }
}
