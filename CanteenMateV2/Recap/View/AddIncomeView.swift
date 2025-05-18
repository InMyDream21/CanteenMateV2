//
//  AddIncomeView.swift
//  CanteenMateV2
//
//  Created by Ahmed Nizhan Haikal on 16/05/25.
//

import Foundation
import SwiftUI
import SwiftData

enum addIncomeMode: String, CaseIterable {
    case predefined = "Menu"
    case custom = "Custom"
}

struct AddIncomeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var selectedMode: addIncomeMode = .predefined
    @State private var selectedDate = Date()
    @State private var quantities: [UUID:Int] = [:]
    @State var title: String = ""
    @State var amount: String = ""
    @State var description: String = ""
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    @Query private var allMenus: [Menu]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var totalPrice: Int {
        allMenus.reduce(0) { total, item in
            let quantity = quantities[item.id] ?? 0
            return total + Int(quantity) * item.price
        }
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
                
                Text("Add Income")
                    .font(.title2.bold())
                Spacer()
                Spacer()
            }
            .padding(.bottom, 8)
            
            Picker("Recap Filter", selection: $selectedMode) {
                ForEach(addIncomeMode.allCases, id:\.self) { filter in
                    Text(filter.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .padding(.horizontal)
            
            if selectedMode == .predefined {
                ScrollView {
                    LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                        ForEach(allMenus) { item in
                            PredefinedMenuCard(item: item,
                                         quantity: quantities[item.id] ?? 0,
                                         onTap: {
                                quantities[item.id, default: 0] += 1
                            },
                                         onAdd: {
                                quantities[item.id, default: 0] += 1
                            },
                                         onRemove: {
                                quantities[item.id, default: 0] = max(0, (quantities[item.id] ?? 0) - 1)
                            })
                        }
                    }
                }
                .padding()
            } else {
                CustomIncomeExpenseForm(selectedDate: $selectedDate, title: $title, amount: $amount, description: $description)
            }
            
            if selectedMode == .predefined {
                HStack {
                    Text("Total")
                        .fontWeight(.bold)
                    Spacer()
                    Text("Rp\(formatToIdr(totalPrice))")
                        .fontWeight(.bold)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            
            Button(action: {
                if selectedMode == .predefined {
                    for (id, quantity) in quantities where quantity > 0 {
                        if let menu = allMenus.first(where: { $0.id == id }) {
                            let newTransaction = Transaction(
                                name: menu.name,
                                date: selectedDate,
                                amount: Int(menu.price * quantity),
                                type: .income,
                                count: quantity
                            )
                            modelContext.insert(newTransaction)
                            try? modelContext.save()
                        }
                    }
                } else {
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
                    let newTransaction = Transaction(name: title, date: selectedDate, amount: priceValue, type: .income, count: 1, desc: description)
                    modelContext.insert(newTransaction)
                    try? modelContext.save()
                }
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
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let modelContainer = try! ModelContainer(for: Menu.self, configurations: config)
    
    let context = modelContainer.mainContext
    
    let dummyData = [
        Menu(name:"Mie Ayam", price: 15000),
        Menu(name:"Bakso", price: 15000),
        Menu(name:"Es Jeruk", price: 10000),
    ]
    
    dummyData.forEach { context.insert($0) }
    
    return AddIncomeView()
        .modelContainer(modelContainer)
}
