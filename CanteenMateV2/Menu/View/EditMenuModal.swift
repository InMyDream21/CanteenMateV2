//
//  EditMenuModal.swift
//  CanteenMateV2
//
//  Created by Ahmed Nizhan Haikal on 09/05/25.
//

import SwiftUI

struct EditMenuModal: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    @State private var showDeleteConfirmation = false
    
    let originalItem: Menu
    
    @State private var name: String = ""
    @State private var price: String = ""
    
    init(item: Menu) {
        self.originalItem = item
        _name = State(initialValue: item.name)
        _price = State(initialValue: String(item.price))
    }
    
    var body: some View {
        VStack{
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.blue)
                .padding(.vertical)
                .padding(.leading, 22)
                Spacer()
                
                Text("Edit Menu")
                    .font(.title2.bold())
                Spacer()
            }
            .padding(.bottom, 8)
            
            Form {
                TextField("Name", text: $name)
                    .padding(.leading, 6)
                TextField("Price", text: $price)
                    .keyboardType(.decimalPad)
                    .padding(.leading, 6)
                    .onChange(of: price) {
                        // Allow only numbers and one optional dot
                        let filtered = price.filter { "0123456789.".contains($0) }
                        let dotCount = filtered.filter { $0 == "." }.count
                        
                        if filtered != price || dotCount > 1 {
                            // Remove extra dots or invalid chars
                            let clean = price
                                .components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted)
                                .joined()
                            
                            // Limit to one decimal point
                            var dotSeen = false
                            let cleaned = clean.filter {
                                if $0 == "." {
                                    if dotSeen { return false }
                                    dotSeen = true
                                }
                                return true
                            }
                            
                            price = cleaned
                        }
                    }
            }
            Button(action: {
                if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    validationMessage = "Name cannot be empty."
                    showValidationAlert = true
                    return
                }
                
                if price.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    validationMessage = "Price cannot be empty."
                    showValidationAlert = true
                    return
                }
                
                guard let priceValue = Int(price) else {
                    validationMessage = "Price must be a valid number."
                    showValidationAlert = true
                    return
                }
                
                originalItem.name = name
                originalItem.price = Int(priceValue)
                try? modelContext.save()
                dismiss()
            }) {
                Label("Save", systemImage: "doc.on.doc")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .background(Color(.systemGray6))
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
                    modelContext.delete(originalItem)
                    try? modelContext.save()
                    dismiss()
                }
            }
            .padding(.bottom, 24)
        }
        .background(Color(.systemGray6))
        
    }
}

#Preview {
    EditMenuModal(item: Menu(name: "Bakso", price: 10000))
}
