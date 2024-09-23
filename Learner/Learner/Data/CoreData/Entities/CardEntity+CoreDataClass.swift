//
//  Card+CoreDataClass.swift
//  CardsLearner
//
//  Created by Andrii Tishchenko on 2024-09-17.
//
//

import Foundation
import CoreData

@objc(CardEntity)
public class CardEntity: NSManagedObject {

}

extension CardEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CardEntity> {
        return NSFetchRequest<CardEntity>(entityName: "CardEntity")
    }

    @NSManaged public var uid: Int32
    @NSManaged public var categoryId: Int32
    @NSManaged public var title: String?
    @NSManaged public var imageURL: URL?
    @NSManaged public var voice: String?
    @NSManaged public var transcription: String?
    @NSManaged public var translate: String?
    @NSManaged public var lang: String?

}

extension CardEntity : Identifiable {

}
