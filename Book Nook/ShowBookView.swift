//
//  ShowBookView.swift
//  ZBook
//
//  Created by Benjamin Shabowski on 9/7/22.
//

import SwiftUI

struct ShowBookView: View {
    
    @State var book : Book
    
    @Binding var isPresented: Bool
    @State var timesRead : Int32 = 0
    
    @Environment(\.managedObjectContext) var viewContext

    var body: some View {
        Spacer()
        Text("\(book.title!)").font(.title)
        Text("\(book.author!)").font(.subheadline)
        Spacer()
        Stepper("Times read: \(timesRead)",
                onIncrement: {
                    timesRead += 1
                    book.timesRead = timesRead
                    do {
                        try viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError) on add, \(nsError.userInfo)")
                    }
                },
                onDecrement: {
                    if(timesRead > 0){
                        timesRead -= 1
                        book.timesRead = timesRead
                        do {
                            try viewContext.save()
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError) on add, \(nsError.userInfo)")
                        }
                    }
                }).onAppear(perform: {
                    timesRead = book.timesRead
                }
        ).padding()
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
