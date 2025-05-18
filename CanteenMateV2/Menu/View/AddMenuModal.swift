//
//  AddMenuModal.swift
//  CanteenMateV2
//
//  Created by Ahmed Nizhan Haikal on 09/05/25.
//

import SwiftUI

struct AddMenuModal: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    @State private var name: String = ""
    @State private var price: String = ""
    
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
                
                Text("Add Menu")
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
                        let filtered = price.filter { "0123456789.".contains($0) }
                        let dotCount = filtered.filter { $0 == "." }.count
                        
                        if filtered != price || dotCount > 1 {
                            let clean = price
                                .components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted)
                                .joined()
                            
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
                
                let newMenu: Menu = Menu(name: name, price: priceValue)
                modelContext.insert(newMenu)
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
        }
        .background(Color(.systemGray6))
        
    }
}

#Preview {
    AddMenuModal()
}
