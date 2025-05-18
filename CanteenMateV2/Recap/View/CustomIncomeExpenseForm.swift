//
//  CustomIncomeExpenseForm.swift
//  CanteenMateV2
//
//  Created by Ahmed Nizhan Haikal on 17/05/25.
//

import Foundation
import SwiftUI

struct CustomIncomeExpenseForm: View {
    @Binding var selectedDate: Date
    @Binding var title: String
    @Binding var amount: String
    @Binding var description: String
    
    var body: some View {
        Form {
            TextField("Title", text: $title)
            HStack {
                Text("Rp")
                    .foregroundColor(.gray)
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                    .onChange(of: amount) {
                        let filtered = amount.filter { "0123456789.".contains($0) }
                        let dotCount = filtered.filter { $0 == "." }.count
                        
                        if filtered != amount || dotCount > 1 {
                            let clean = amount
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
                            
                            amount = cleaned
                        }
                    }
            }
            ZStack(alignment: .topLeading) {
                if description.isEmpty {
                    Text("Description")
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                        .opacity(0.5)
                }
                TextEditor(text: $description)
                    .padding(4)
            }
            .frame(height: 100)
        }.listStyle(InsetListStyle())
    }
}

struct CustomIncomeExpenseForm_Preview: PreviewProvider {
    struct Preview: View {
        @State var selectedDate: Date = Date()
        @State var title: String = ""
        @State var amount: String = ""
        @State var description: String = ""
        
        var body: some View {
            CustomIncomeExpenseForm(selectedDate: $selectedDate, title: $title, amount: $amount, description: $description)
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
