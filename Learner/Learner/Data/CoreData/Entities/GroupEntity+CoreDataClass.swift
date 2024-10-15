//
//  Group+CoreDataClass.swift
//  CardsLearner
//
//  Created by Andrii Tishchenko on 2024-09-17.
//
//

import Foundation
import CoreData

@objc(GroupEntity)
public class GroupEntity: NSManagedObject {

}

extension GroupEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GroupEntity> {
        return NSFetchRequest<GroupEntity>(entityName: "GroupEntity")
    }

    @NSManaged public var title: String?
    @NSManaged public var uid: Int32
    @NSManaged public var imageURL: URL?
    @NSManaged public var cards: NSSet?
    @NSManaged public var order: Int32

}

// MARK: Generated accessors for cards
extension GroupEntity {

    @objc(addCardsObject:)
    @NSManaged public func addToCards(_ value: CardEntity)

    @objc(removeCardsObject:)
    @NSManaged public func removeFromCards(_ value: CardEntity)

    @objc(addCards:)
    @NSManaged public func addToCards(_ values: NSSet)

    @objc(removeCards:)
    @NSManaged public func removeFromCards(_ values: NSSet)

}

extension GroupEntity : Identifiable {

}
