//
//  TransactionModel.swift
//  CanteenMateV2
//
//  Created by Ahmed Nizhan Haikal on 14/05/25.
//

import Foundation
import SwiftData

@Model
class Transaction: Identifiable {
    var id: UUID
    var name: String
    var date: Date
    var amount: Int
    var type: TransactionType
    var count: Int
    var desc: String?
    
    init(id:UUID = UUID(), name: String, date: Date, amount: Int, type: TransactionType, count: Int, desc: String? = nil) {
        self.id = id
        self.name = name
        self.date = date
        self.amount = amount
        self.type = type
        self.count = count
        self.desc = desc
    }
}

enum TransactionType: String, CaseIterable, Codable {
    case income = "Income"
    case expense = "Expense"
}

extension Transaction {
    static func fetchForMonth(_ date: Date, in context: ModelContext) throws -> [Transaction] {
        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return []
        }

        let descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate { transaction in
                transaction.date >= startOfMonth && transaction.date <= endOfMonth
            },
            sortBy: [SortDescriptor(\.date)]
        )

        return try context.fetch(descriptor)
    }
}
