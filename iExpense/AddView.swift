//
//  AddView.swift
//  iExpense
//
//  Created by Steven Gustason on 4/6/23.
//

import SwiftUI

// Second view for an add expense form
struct AddView: View {
    // Variables to track the expense name, type, and amount
    @State private var name = ""
    @State private var type = "Personal"
    @State private var amount = 0.0

    // Variable to track the two types of expense
    let types = ["Business", "Personal"]
    
    // Property to store an Expenses object. Since we don't want to create a second instance of Expenses, we use ObservedObject instead of StateObject
    @ObservedObject var expenses: Expenses
    
    // Property to dismiss our sheet
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                // Text field to enter the name of the expense
                TextField("Name", text: $name)

                // Picker to choose between the two types
                Picker("Type", selection: $type) {
                    ForEach(types, id: \.self) {
                        Text($0)
                    }
                }

                // Text field to enter the amount of the expense
                TextField("Amount", value: $amount, format: .currency(code: "USD"))
                    .keyboardType(.decimalPad)
            }
            // Title for new view
            .navigationTitle("Add new expense")
            // Here we add a button that has a variable item, set to an expense item with all of our user's input data. Then we append that new variable to our expenses.items ExpenseItems array
            .toolbar {
                Button("Save") {
                    let item = ExpenseItem(name: name, type: type, amount: amount)
                    expenses.items.append(item)
                    
                    // Call dismiss to dismiss our view
                    dismiss()
                }
            }
        }
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView(expenses: Expenses())
    }
}
