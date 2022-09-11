//
//  BookShelf+CoreDataProperties.swift
//  ZBook
//
//  Created by Benjamin Shabowski on 9/10/22.
//
//

import Foundation
import CoreData


extension BookShelf {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookShelf> {
        return NSFetchRequest<BookShelf>(entityName: "BookShelf")
    }

    @NSManaged public var name: String?
    @NSManaged public var books: NSSet?

    public var unwrappedName : String {
        name ?? "Unknown name"
    }
    
    public var bookArray: [Book] {
        let set = books as? Set<Book> ?? []
        
        return set.sorted {
            if($0.unwrappedAuthor == $1.unwrappedAuthor){
                return $0.unwrappedTitle < $1.unwrappedTitle
            } else {
                return $0.unwrappedAuthor < $1.unwrappedAuthor
            }
        }
    }
}

// MARK: Generated accessors for books
extension BookShelf {

    @objc(addBooksObject:)
    @NSManaged public func addToBooks(_ value: Book)

    @objc(removeBooksObject:)
    @NSManaged public func removeFromBooks(_ value: Book)

    @objc(addBooks:)
    @NSManaged public func addToBooks(_ values: NSSet)

    @objc(removeBooks:)
    @NSManaged public func removeFromBooks(_ values: NSSet)

}

extension BookShelf : Identifiable {

}
