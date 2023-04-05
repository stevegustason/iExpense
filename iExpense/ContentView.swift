//
//  ContentView.swift
//  iExpense
//
//  Created by Steven Gustason on 4/5/23.
//

import SwiftUI

// If we want to share data across views, we need to use a class rather than a struct. If we have two views both working with the same struct, they will both have a unique instance of that struct and any data changed in one view won't be seen in the other. However, if we use an instance of a class, any changes made are reflected in all places since instances of a class point to the same data everywhere. We also need our class to conform to the ObservableObject protocol, which has no requirements, but essentially says that we want other things to be able to monitor this class for changes.
class User: ObservableObject {
    // The @Published property observer allows us to notify any views whenever these items change so our view can be reloaded
    @Published var firstName = "Bilbo"
    @Published var lastName = "Baggins"
}

// The codable protocol is specifically for archiving and unarchiving data, which can be great for use with UserDefaults
struct Person: Codable {
    let firstName: String
    let lastName: String
}

struct SecondView: View {
    // If a view requires parameters, Swift will automatically make sure that you must pass in those parameters or your code won't compile
    let name: String
    
    // The environment property wrapper allows us to create properties that store values given to us externally. Here, we're essentially saying "figure out how my view was presented, then dismiss it appropriately."
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Text("Hello, \(name)!")
        
        // Then we can use this button to dismiss our view
        Button("Dismiss") {
            dismiss()
        }
    }
}

struct ContentView: View {
    // The @StateObject property wrapper tells SwiftUI that we're creating a new class instance that should be watched for class change announcements
    @StateObject var user = User()
    // Sheets are like alerts - we need to define the conditions in which they will show then trigger those conditions. In this case, we use this variable to track when it should show.
    @State private var showingSheet = false
    
    @State private var numbers = [Int]()
    @State private var currentNumber = 1
    
    // To make onDelete work, we need a method that will receive a single parameter of type IndexSet, which basically tells us the position of the items in the ForEach that needs to be removed
    func removeRows(at offsets: IndexSet) {
        numbers.remove(atOffsets: offsets)
    }
    
    /*
    // We can read our UserDefaults data back like so.
    @State private var tapCount = UserDefaults.standard.integer(forKey: "Tap")*/
    
    // In really simple situations you can use the @AppStorage property wrapper to essentially ignore UserDefaults entirely and just use @AppStorage instead of @State
    @AppStorage("tapCount") private var tapCount = 0
    
    // Here we create an instance of our codable struct
    @State private var person = Person(firstName: "Taylor", lastName: "Swift")

    var body: some View {
        NavigationView {
            VStack {
                // We can then create a button that archives the user data and saves it to UserDefaults
                Button("Save User") {
                    // First, we set the type of encoder we're using, which is usually JSON since it's fast and simple
                    let encoder = JSONEncoder()

                    // Encoding can throw errors so we want to use try or try? to handle errors. We then call the encode() method on our encoder to convert our user to JSON data. The data constant is a data type called Data that can store basically any kind of data.
                    if let data = try? encoder.encode(person) {
                        UserDefaults.standard.set(data, forKey: "UserData")
                    }
                }
                
                Button("Tap count: \(tapCount)") {
                    tapCount += 1
                    
                    /*
                    // We can use UserDefaults to store small amounts of data tied to a user. This is great for simple preferences. Here we're tracking how many times the user taps the button.
                    UserDefaults.standard.set(self.tapCount, forKey: "Tap")*/
                    
                        }
                
                Text("Your name is \(user.firstName) \(user.lastName).")
                
                TextField("First name", text: $user.firstName)
                TextField("Last name", text: $user.lastName)
                
                Button("Show Sheet") {
                    // We set our button to toggle our sheet condition tracking variable
                    showingSheet.toggle()
                }
                // Then we use .sheet similar to .alert and specific when it should be presented
                .sheet(isPresented: $showingSheet) {
                    // Then we specify what specifically we want in our sheet, in this case to create and show an instance of SecondView
                    SecondView(name: "@stevegustason")
                }
                
                List {
                    ForEach(numbers, id: \.self) {
                        Text("Row \($0)")
                    }
                    // We can use onDelete to delete data, but it only works on ForEach. When you add this and pass our function, you can then swipe right to left on the rows to delete them.
                    .onDelete(perform: removeRows)
                }
                
                Button("Add Number") {
                    numbers.append(currentNumber)
                    currentNumber += 1
                }
            }
            // We can also add an edit button to delete multiple rows at a time
            .toolbar {
                EditButton()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
