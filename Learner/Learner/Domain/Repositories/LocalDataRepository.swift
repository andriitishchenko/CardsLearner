protocol LocalDataRepository {    
    func saveGroup(_ group: GroupEntity) async throws
    func saveGroups(_ groups: [GroupEntity]) async throws
    func fetchGroups() async throws -> [GroupEntity]
    func saveCard(_ card: CardEntity, toGroup group: GroupEntity) async throws
    func fetchCards(forGroup group: GroupEntity) async throws -> [CardEntity]
    
    func newCardEntity() -> CardEntity
    func newGroupEntity() -> GroupEntity
    
    func cleanup() async throws
}
