//
//  ShowBookView.swift
//  ZBook
//
//  Created by Benjamin Shabowski on 9/7/22.
//

import SwiftUI

struct ShowBookView: View {
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BookShelf.name, ascending: true)],
        animation: .default)
    private var bookShelves: FetchedResults<BookShelf>
    
    @State var book : Book
    
    @Binding var isPresented: Bool
    @State var timesRead : Int32 = 0
    @State var selectedBookShelf: BookShelf
    
    @Environment(\.managedObjectContext) var viewContext

    var body: some View {
        Spacer()
        Text("\(book.title ?? "Nothing")").font(.title)
        Text("\(book.author ?? "Nothing")").font(.subheadline)
        Spacer()
        HStack {
            Text("Book shelf: ")
            Picker("Book Shelf", selection: $selectedBookShelf) {
                   ForEach(bookShelves) { shelf in
                       Text(shelf.name ?? "Deleted Shelf").tag(shelf)
                   }
            }
            .pickerStyle(.menu)
            .onChange(of: selectedBookShelf, perform: {newValue in
                book.bookShelf = newValue
                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError) on add, \(nsError.userInfo)")
                }
            })
        }.padding()
        Spacer()
        Text("Added \(formatDate(date: book.added ?? Date.now))")
        Spacer()
    }
    
    private func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: date)
    }
}
