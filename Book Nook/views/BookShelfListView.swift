//
//  BookShelfListView.swift
//  ZBook
//
//  Created by Benjamin Shabowski on 9/29/22.
//

import SwiftUI

struct BookShelfListView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Book.author, ascending: true), NSSortDescriptor(keyPath: \Book.title, ascending: true)],
        animation: .default)
    private var books: FetchedResults<Book>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(
            keyPath: \BookShelf.priority,
            ascending: true)],
        animation: .default)
    private var bookShelves: FetchedResults<BookShelf>
    
    @State private var presentDeleteShelf = false
    @State private var presentEditShelf = false
    
    @State private var shelfToDelete : BookShelf?
    @State private var shelfToEdit: BookShelf?
    
    @Binding var canAddBook : Bool
    
    var body: some View {
        NavigationView {
            List {
                ForEach(bookShelves) { bookShelf in
                    NavigationLink {EditShelfView(shelf: bookShelf, isPresented: $presentEditShelf)} label: {
                        HStack{
                            Text(bookShelf.name!).foregroundColor(bookShelf.color)
                            Spacer()
                            Button(action: {
                                shelfToDelete = bookShelf
                                presentDeleteShelf = true
                            }){
                                Label("", systemImage: "trash").foregroundColor(.red)
                            }
                            Label("", systemImage: "line.3.horizontal")
                        }
                    }
                }.onMove(perform: move)
            }.navigationTitle("Bookshelf Settings")
            .alert(isPresented: $presentDeleteShelf) {
                Alert(title: Text("Are you sure you want to delete this shelf?"),
                      message: Text("This will also delete all the books in this shelf"),
                      primaryButton: .destructive(Text("Delete")) {
                    deleteShelf(shelf: shelfToDelete!)
                },
                      secondaryButton: .cancel())
            }
        }
    }
    
    private func move( from source: IndexSet, to destination: Int){
        // Make an array of items from fetched results
        var revisedItems: [ BookShelf ] = bookShelves.map{ $0 }

        // change the order of the items in the array
        revisedItems.move(fromOffsets: source, toOffset: destination )
        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1 ){
            revisedItems[ reverseIndex ].priority =
                Int64( reverseIndex )
        }
    }
    
    private func deleteShelf(shelf: BookShelf) {
        for book in shelf.bookArray {
            deleteBook(book: book)
        }
        
        var index = 0
        
        for currentShelf in bookShelves {
            if(currentShelf.name == shelf.name){
                break;
            }
            index += 1
        }
        
        withAnimation {
            [index].map { bookShelves[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
        canAddBook = !bookShelves.isEmpty
    }
    
    private func deleteBook(book: Book){
        var index = 0
        for currentBook in books {
            if(currentBook.title == book.title && currentBook.author == book.author){
                deleteItems(offsets: [index])
            }
            index += 1
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { books[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
