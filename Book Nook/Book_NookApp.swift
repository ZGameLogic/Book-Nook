//
//  Book_NookApp.swift
//  Book Nook
//
//  Created by Benjamin Shabowski on 9/4/22.
//

import SwiftUI

@main
struct Book_NookApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
