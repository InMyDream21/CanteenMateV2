//
//  GroupedTransaction.swift
//  CanteenMateV2
//
//  Created by Ahmed Nizhan Haikal on 16/05/25.
//

import Foundation

struct GroupedTransaction: Identifiable {
    let id = UUID()
    let date: Date
    let totalAmount: Int
}
