//
//  EditTransactionView.swift
//  CanteenMateV2
//
//  Created by Ahmed Nizhan Haikal on 18/05/25.
//

import Foundation
import SwiftUI

struct EditTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let originalTransaction: Transaction
    
    @State var selectedDate: Date
    @State var title: String = ""
    @State var amount: String = ""
    @State var description: String = ""
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    @State var showDeleteConfirmation: Bool = false
    
    init(transaction: Transaction) {
        self.originalTransaction = transaction
        self._title = State(initialValue: transaction.name)
        self._amount = State(initialValue: String(transaction.amount))
        self._description = State(initialValue: transaction.desc ?? "")
        self._selectedDate = State(initialValue: transaction.date)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.blue)
                .padding(.vertical)
                .padding(.leading, 22)
                Spacer()
                
                Text(originalTransaction.type == .income ? "Edit Income" : "Edit Expense")
                    .font(.title2.bold())
                Spacer()
                Spacer()
            }
            .padding(.bottom, 8)
            
            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .padding(.horizontal)
            
            CustomIncomeExpenseForm(selectedDate: $selectedDate, title: $title, amount: $amount, description: $description)
            
            Button(action: {
                if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    validationMessage = "Name cannot be empty."
                    showValidationAlert = true
                    return
                }
                
                if amount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    validationMessage = "Price cannot be empty."
                    showValidationAlert = true
                    return
                }
                
                guard let priceValue = Int(amount) else {
                    validationMessage = "Price must be a valid number."
                    showValidationAlert = true
                    return
                }
                originalTransaction.name = title
                originalTransaction.amount = Int(priceValue)
                originalTransaction.desc = description
                try? modelContext.save()
                
                dismiss() // Optionally dismiss the view after saving
            }) {
                Label("Save", systemImage: "clipboard")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding()
            .alert("Invalid Input", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(validationMessage)
            }
            
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
                    .font(.headline)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
            }
            .confirmationDialog("Are you sure you want to delete this menu?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    modelContext.delete(originalTransaction)
                    try? modelContext.save()
                    dismiss()
                }
            }
            .padding(.bottom, 24)
        }
        .background(Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? .black : .systemGray6
        }))
    }
}

#Preview {
    EditTransactionView(transaction: Transaction(name: "Bakso", date: Date(), amount: 15000, type: .income, count: 1))
}
