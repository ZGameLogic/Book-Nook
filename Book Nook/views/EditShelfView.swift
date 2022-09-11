//
//  EditShelfView.swift
//  ZBook
//
//  Created by Benjamin Shabowski on 9/11/22.
//

import SwiftUI

struct EditShelfView: View {
    @Environment(\.managedObjectContext) var viewContext
    @State var inputName = ""
    
    @State var shelf : BookShelf
    
    @State private var errorMessage = ""
    @State private var showError = false
    
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12){
                HStack {
                    Text("Name:")
                    TextField("Enter Name", text: $inputName).textFieldStyle(.roundedBorder)
                }.padding()
                Spacer()
            }
            .navigationBarTitle("Edit Shelf")
            .toolbar {
                ToolbarItem (placement: .navigationBarLeading) {
                    Button {
                        isPresented = false
                    } label: {
                        Text("Cancel").foregroundColor(.red)
                    }
                }
                ToolbarItem {
                    Button {
                        if(!inputName.isEmpty){
                            saveShelf(name: inputName)
                            isPresented = false
                        } else {
                            errorMessage = "Please input a name"
                            showError = true
                        }
                    } label: {
                        Text("Save")
                    }
                }
            }
        }.alert("Missing information",
                isPresented: $showError,
                actions: {
                Button("Okay", action: {})
            }, message: {
                Text("\(errorMessage)")
            })
        .onAppear(){
            inputName = shelf.unwrappedName
        }
    }
    
    func saveShelf(name: String){
        let newName = name.trimmingCharacters(in: .whitespaces)
        
        if(!name.isEmpty){
            shelf.name = newName
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError) on add, \(nsError.userInfo)")
            }
        }
    }
}
