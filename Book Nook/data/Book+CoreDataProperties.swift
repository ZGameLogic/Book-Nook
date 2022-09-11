//
//  Book+CoreDataProperties.swift
//  ZBook
//
//  Created by Benjamin Shabowski on 9/10/22.
//
//

import Foundation
import CoreData


extension Book {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book")
    }

    @NSManaged public var added: Date?
    @NSManaged public var author: String?
    @NSManaged public var timesRead: Int32
    @NSManaged public var title: String?
    @NSManaged public var bookShelf: BookShelf?
    
    public var unwrappedAuthor: String {
        author ?? "No author"
    }

    public var unwrappedTitle: String {
        title ?? "No title"
    }
    
    public var unwrappedDateAdded: Date {
        added ?? Date.now
    }
    
}

extension Book : Identifiable {

}
