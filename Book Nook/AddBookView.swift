//
//  AddBookView.swift
//  Book Nook
//
//  Created by Benjamin Shabowski on 9/5/22.
//

import SwiftUI

struct AddBookView: View {
    
    enum FocusField: Hashable {
        case field
      }
    
    @Environment(\.managedObjectContext) var viewContext
    @State private var inputTitle = ""
    @State private var inputAuthor = ""
    @Binding var isPresented: Bool
    
    @FocusState private var focusedField: FocusField?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                HStack {
                    Text("Title:")
                    TextField("Enter Title", text: $inputTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($focusedField, equals: .field)
                        .onAppear {
                            self.focusedField = .field
                        }
                }
                
                HStack {
                    Text("Author:")
                    TextField("Enter Author", text: $inputAuthor)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                Spacer()
                Button {
                    saveBook(title: inputTitle, author: inputAuthor)
                    isPresented = false
                } label: {
                    Text("Save and close")
                }.padding()
                Button {
                    saveBook(title: inputTitle, author: inputAuthor)
                    inputTitle = ""
                    inputAuthor = ""
                    focusedField = .field
                } label: {
                    Text("Save and add another")
                }.padding()
                Button {
                    inputTitle = ""
                    inputAuthor = ""
                    isPresented = false
                } label: {
                    Text("Cancel").foregroundColor(.red)
                }.padding()

            }
            .padding()
            .navigationBarTitle("Add Book")
        }
    }
    
    func saveBook(title: String, author: String){
        let newTitle = title.trimmingCharacters(in: .whitespaces)
        let newAuthor = author.trimmingCharacters(in: .whitespaces)
        if !newTitle.isEmpty && !newAuthor.isEmpty {
            let newBook = Book(context: viewContext)
            newBook.title = newTitle
            newBook.author = newAuthor
            newBook.added = Date.now
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError) on add, \(nsError.userInfo)")
            }
        }
    }
}

struct AddBookView_Previews: PreviewProvider {
    
    @State static var isPresented = true
    
    static var previews: some View {
        AddBookView(isPresented: $isPresented)
    }
}
