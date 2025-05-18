//
//  AddExpenseView.swift
//  CanteenMateV2
//
//  Created by Ahmed Nizhan Haikal on 16/05/25.
//

import Foundation
import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State var selectedDate: Date = Date()
    @State var title: String = ""
    @State var amount: String = ""
    @State var description: String = ""
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    
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
                
                Text("Add Expense")
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
                let newTransaction = Transaction(name: title, date: selectedDate, amount: priceValue, type: .expense, count: 1, desc: description)
                modelContext.insert(newTransaction)
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
        }
        .background(Color(.systemGray6))
    }
}

#Preview {
    AddExpenseView()
}
