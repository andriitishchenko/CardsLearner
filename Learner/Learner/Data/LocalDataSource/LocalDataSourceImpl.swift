import CoreData

class LocalDataSourceImpl: LocalDataSource {
    
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

    // MARK: - Cleanup

    func cleanup() async throws {
        let fetchRequestGroups: NSFetchRequest<NSFetchRequestResult> = GroupEntity.fetchRequest()
        let deleteRequestGroups = NSBatchDeleteRequest(fetchRequest: fetchRequestGroups)
        
        let fetchRequestCards: NSFetchRequest<NSFetchRequestResult> = CardEntity.fetchRequest()
        let deleteRequestCards = NSBatchDeleteRequest(fetchRequest: fetchRequestCards)
        
        do {
            try context.execute(deleteRequestGroups)
            try context.execute(deleteRequestCards)
            context.reset()
            try await self.saveContext()
        } catch {
            throw error
        }
    }
    
    func saveContext() async throws{
        try context.save()
        try await Task.sleep(for: .seconds(2))
        print("context saved")
    }
}
