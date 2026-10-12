import CoreData

@MainActor
final class LocalDataSourceImpl: LocalDataSource {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func newCardEntity() -> CardEntity {
        return CardEntity(context: context)
    }
    
    func newGroupEntity() -> GroupEntity {
        return GroupEntity(context: context)
    }
    
    
    // MARK: - Group Operations
    
    func saveGroup(_ group: GroupEntity) async throws {
        context.insert(group)
        try await saveContext()
    }
    
    func saveGroups(_ groups: [GroupEntity]) async throws {
        print("saveGroups:")
        for group in groups {
            context.insert(group)
        }
        try await saveContext()
    }

    func replaceGroups(_ groups: [GroupEntity]) async throws {
        do {
            let replacementGroupIDs = Set(groups.map(\.objectID))
            let existingGroups = try context.fetch(GroupEntity.fetchRequest()).filter {
                !$0.isInserted && !replacementGroupIDs.contains($0.objectID)
            }
            let existingCards = try context.fetch(CardEntity.fetchRequest()).filter { !$0.isInserted }

            for card in existingCards {
                context.delete(card)
            }
            for group in existingGroups {
                context.delete(group)
            }
            for group in groups {
                context.insert(group)
            }

            try await saveContext()
        } catch {
            context.rollback()
            throw error
        }
    }
    
    func fetchGroups() async throws -> [GroupEntity] {
        print("fetchGroups")
        let fetchRequest: NSFetchRequest<GroupEntity> = GroupEntity.fetchRequest()
        
        do {
            let groups = try context.fetch(fetchRequest)
            return groups
        } catch {
            throw error
        }
    }

    // MARK: - Card Operations
    
    func saveCard(_ card: CardEntity, toGroup group: GroupEntity) async throws {
        group.addToCards(card)
        context.insert(card)
        
        do {
           try await saveContext()
        } catch {
            throw error
        }
    }
    
    func fetchCards(forGroup group: GroupEntity) async throws -> [CardEntity] {
        guard let cards = group.cards as? Set<CardEntity> else {
            return []
        }
        return Array(cards)
    }

    func saveContext() async throws{
        try context.save()
        print("context saved")
    }
}
