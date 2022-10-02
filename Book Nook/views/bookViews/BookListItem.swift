//
//  BookListItem.swift
//  ZBook
//
//  Created by Benjamin Shabowski on 10/2/22.
//

import SwiftUI

struct BookListItem: View {
    
    @State var book : Book
    @Binding var showViewBook : Bool
    
    var body: some View {
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
