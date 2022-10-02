//
//  AddBookView.swift
//  Book Nook
//
//  Created by Benjamin Shabowski on 9/5/22.
//

import SwiftUI

public struct AddBookView: View {
    
    enum FocusField: Hashable {
        case field
      }
    
    @Environment(\.managedObjectContext) var viewContext
    @State var inputTitle = ""
    @State var inputAuthor = ""
    @State var addAnother = false
    
    @State var errorMessage = ""
    @State var showError = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Book.author, ascending: true), NSSortDescriptor(keyPath: \Book.title, ascending: true)],
        animation: .default)
    private var books: FetchedResults<Book>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BookShelf.name, ascending: true)],
        animation: .default)
    private var bookShelves: FetchedResults<BookShelf>
    
    @State var pickedShelf: BookShelf
    
    @Binding var isPresented: Bool
    
    @FocusState var focusedField: FocusField?
    
    public var body: some View {
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
                HStack {
                    Text("Book shelf: ")
                    if(bookShelves.count < 4){
                        Picker("Book Shelf", selection: $pickedShelf) {
                               ForEach(bookShelves) { shelf in
                                   Text(shelf.name!).tag(shelf)
                               }
                        }.pickerStyle(.segmented)
                    } else {
                        Picker("Book Shelf", selection: $pickedShelf) {
                               ForEach(bookShelves) { shelf in
                                   Text(shelf.name!).tag(shelf)
                               }
                        }.pickerStyle(.menu)
                    }
                    Spacer()
                }
                Toggle(isOn: $addAnother) {
                    Text("Add another:")
                }
                Spacer()
            }
            .padding()
            .navigationBarTitle("Add Book")
            .toolbar {
                ToolbarItem (placement: .navigationBarLeading) {
                    Button {
                        inputTitle = ""
                        inputAuthor = ""
                        if(pickedShelf.name == "Unshelved" && pickedShelf.bookArray.isEmpty){
                            
                        }
                        isPresented = false
                    } label: {
                        Text("Cancel").foregroundColor(.red)
                    }
                }
                ToolbarItem {
                    Button {
                        if(inputTitle.isEmpty || inputAuthor.isEmpty){
                            errorMessage = ""
                            if(inputTitle.isEmpty){
                                errorMessage = "Please input a title\n"
                            }
                            if(inputAuthor.isEmpty){
                                errorMessage = errorMessage + "Please input an author"
                            }
                            showError = true
                        } else {
                            if(findBook(title: inputTitle, author: inputAuthor)){
                                errorMessage = "Book already exists"
                                showError = true
                            } else {
                                saveBook(title: inputTitle, author: inputAuthor, bookShelf: pickedShelf)
                                if(addAnother){
                                    inputTitle = ""
                                    inputAuthor = ""
                                    focusedField = .field
                                } else {
                                    isPresented = false
                                }
                            }
                        }
                    } label: {
                        Text("Save")
                    }
                }
            }.alert("Unable to add book",
                     isPresented: $showError,
                     actions: {
                     Button("Okay", action: {})
                 }, message: {
                     Text("\(errorMessage)")
                 })
        }
    }
    
    func saveBook(title: String, author: String, bookShelf: BookShelf){
        let newTitle = title.trimmingCharacters(in: .whitespaces)
        let newAuthor = author.trimmingCharacters(in: .whitespaces)
        if !newTitle.isEmpty && !newAuthor.isEmpty {
            let newBook = Book(context: viewContext)
            newBook.title = newTitle
            newBook.author = newAuthor
            newBook.added = Date.now
            let savedBookShelf = bookShelf
            newBook.bookShelf = savedBookShelf
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError) on add, \(nsError.userInfo)")
            }
        }
    }
    
    func findBook(title: String, author: String) -> Bool {
        var found = false
        for book in books {
            if(book.author == author && book.title == title) {
               found = true
            }
        }
        return found
    }
}
