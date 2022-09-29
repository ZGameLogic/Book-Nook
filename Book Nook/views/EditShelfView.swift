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
    
    @State var shelf : BookShelf?
    @Binding var isPresented: Bool
    
    @State private var errorMessage = ""
    @State private var showError = false
    
    @State private var color = Color.blue
    
    var body: some View {
            VStack(spacing: 12){
                HStack {
                    Text("Name:")
                    TextField("Enter Name", text: $inputName).textFieldStyle(.roundedBorder)
                }.padding()
                ColorPicker("Bookshelf Color", selection: $color).padding()
                Spacer()
            }.alert("Missing information",
                isPresented: $showError,
                actions: {
                Button("Okay", action: {})
            }, message: {
                Text("\(errorMessage)")
            })
        .onAppear(){
            inputName = shelf!.unwrappedName
            color = shelf!.color
        }.onDisappear(){
            saveShelf()
        }
    }
    
    func saveShelf(){
        let newName = inputName.trimmingCharacters(in: .whitespaces)
        if(!newName.isEmpty){
            shelf!.name = newName
        }
        shelf!.colorRed = Double((color.cgColor?.components![0])!)
        shelf!.colorGreen = Double((color.cgColor?.components![1])!)
        shelf!.colorBlue = Double((color.cgColor?.components![2])!)
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError) on add, \(nsError.userInfo)")
        }
    }
}
