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
    
    @State private var showAddBook = false
    
    @State private var presentAlert = false
    
    @State private var randomBookTitle = ""
    @State private var randomBookAuthor = ""

    var body: some View {
        NavigationView {
            List {
                ForEach(books) { book in
                    NavigationLink {
                        Spacer()
                        Text("\(book.title!)").font(.title)
                        Text("\(book.author!)").font(.subheadline)
                        Spacer()
                        Text("Added \(formatDate(date: book.added ?? Date.now))")
                        Spacer()
                        Spacer()
                    } label: {
                        VStack {
                            HStack {
                                Spacer()
                                Text(book.title!)
                            }
                            HStack {
                                Spacer()
                                Text(book.author!).fontWeight(.light).italic()
                            }
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Books")
            .toolbar {
                ToolbarItem (placement: .navigationBarLeading) {
                    Button("Random") {
                        if(!books.isEmpty) {
                            pickRandomBook()
                            presentAlert = true
                        }
                    }
                }
                ToolbarItem {
                    Button(action: {showAddBook = true}) {
                        Label("Add Book", systemImage: "plus")
                    }
                }
            }
            .alert("You should read...",
                        isPresented: $presentAlert,
                        actions: {
                        Button("Thanks", action: {})
                    }, message: {
                        Text("\(randomBookTitle) by \(randomBookAuthor)")
                    })
        }.sheet(isPresented: $showAddBook) {
            AddBookView(isPresented: $showAddBook)
        }
    }
    
    private func pickRandomBook() {
        let book = books.randomElement()
        randomBookTitle = book!.title!
        randomBookAuthor = book!.author!
    }
    
    private func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: date)
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { books[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
