//
//  ContentView.swift
//  Book Nook
//
//  Created by Benjamin Shabowski on 9/5/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
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
    
    @State private var showAddShelf = false
    @State private var showAddBook = false
    @State private var showViewBook = false
    
    @State private var presentAlert = false
    @State private var presentEmptyBook = false
    @State private var canAddBook = false
    
    @State private var presentEditShelf = false
    @State private var shelfToEdit : BookShelf?
    
    @State private var randomBookTitle = ""
    @State private var randomBookAuthor = ""
    
    @State private var bookSearch = ""
    
    @State private var tabOn: Int = 1

    var body: some View {
        TabView(selection: $tabOn) {
            NavigationView {
                List {
                    if(bookShelves.isEmpty) {
                        Text("Add a shelf for your books to go with the icon in the top right")
                    } else {
                        ForEach(bookShelves) { bookShelf in
                            Section(content: {
                                ForEach(bookShelf.bookArray){ book in
                                    NavigationLink {
                                        ShowBookView(book: book, isPresented: $showViewBook, selectedBookShelf: book.bookShelf!)
                                    } label: {
                                        VStack {
                                            HStack{
                                                Spacer()
                                                Text(book.title!).foregroundColor(book.bookShelf?.color)
                                            }
                                            HStack{
                                                Spacer()
                                                Text(book.author!).font(.footnote).italic()
                                            }
                                        }
                                    }
                                }.onDelete(perform: { thing in
                                    deleteBook(book: bookShelf.bookArray[thing.first!])
                                })
                            }, header: {
                                HStack {
                                    Text(bookShelf.name!)
                                    Spacer()
                                    Button(action: {
                                        pickRandom(shelf: bookShelf)
                                    }){
                                        Label("", systemImage: "arrow.triangle.2.circlepath")
                                    }
                                }
                            })
                        }
                    }
                }
                .toolbar {
                    ToolbarItem {
                        Button(action: {showAddShelf = true}) {
                            Label("Add Shelf", systemImage: "books.vertical")
                        } 
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {showAddBook = true}) {
                            Label("Add Book", systemImage: "text.book.closed")
                        }.disabled(!canAddBook)
                    }
                }.navigationTitle("Shelves")
                .alert("You should read...",
                    isPresented: $presentAlert,
                    actions: {
                        Button("Thanks", action: {})
                    }, message: {
                        Text("\(randomBookTitle) by \(randomBookAuthor)")
                    })
                .alert("You have no books on this shelf!",
                    isPresented: $presentEmptyBook,
                    actions: {
                            Button("Thanks", action: {})
                    }, message: {
                        Text("Add a book by using the book icon in the top right")
                    })
            }.sheet(isPresented: $showAddShelf) {
                AddShelfView(isPresented: $showAddShelf)
            }
            .sheet(isPresented: $showAddBook) {
                AddBookView(pickedShelf: bookShelves[0], isPresented: $showAddBook)
            }
            .tabItem({
                Label("Shelves", systemImage: "books.vertical")
            }).tag(1)
                .onAppear(){
                    var index = 0;
                    for bookShelf in bookShelves {
                        if(bookShelf.priority == -1){
                            bookShelf.priority = Int64(index)
                        }
                        index += 1
                    }
                    do {
                        try viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                    canAddBook = !bookShelves.isEmpty
                    for book in books {
                        if(book.bookShelf == nil){
                            deleteBook(book: book)
                        }
                    }
                }.onChange(of: showAddShelf, perform: { v in
                    canAddBook = !bookShelves.isEmpty
                })
            
            NavigationView {
                    List {
                        if(bookShelves.isEmpty) {
                            Text("Add a shelf for your books to go on the shelves screen")
                        } else {
                            ForEach(books) { book in
                                if(bookSearch == "" || (book.title!.lowercased().contains(bookSearch.lowercased()) || book.author!.lowercased().contains(bookSearch.lowercased()))){
                                    NavigationLink {
                                        ShowBookView(book: book, isPresented: $showViewBook, selectedBookShelf: book.bookShelf!)
                                    } label: {
                                        VStack {
                                            HStack {
                                                Spacer()
                                                Text(book.title!).foregroundColor(book.bookShelf?.color)
                                            }
                                            HStack {
                                                Spacer()
                                                Text(book.author!).fontWeight(.light).italic()
                                            }
                                        }
                                    }
                                }
                            }
                            .onDelete(perform: deleteItems)
                        }
                    }.searchable(text: $bookSearch)
                    .navigationTitle("Books")
                    .toolbar {
                        ToolbarItem {
                            Button(action: {showAddBook = true}) {
                                Label("Add Book", systemImage: "plus")
                            }.disabled(!canAddBook)
                        }
                    }
            }.tabItem {
                Label("Books", systemImage: "text.book.closed")
            }.tag(2)
            
            BookShelfListView(canAddBook: $canAddBook).tabItem {
                Label("Settings", systemImage: "gear")
            }.tag(3)
        }
    }
    
    private func pickRandom(shelf: BookShelf){
        if(shelf.bookArray.count == 0) {
            presentEmptyBook = true
        } else {
            let book = shelf.bookArray.randomElement()
            randomBookTitle = book!.unwrappedTitle
            randomBookAuthor = book!.unwrappedAuthor
            presentAlert = true
        }
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
