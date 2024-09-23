protocol LocalDataSource {
    func saveGroup(_ group: GroupEntity) async throws
    func saveGroups(_ groups: [GroupEntity]) async throws
    func fetchGroups() async throws -> [GroupEntity]
    func saveCard(_ card: CardEntity, toGroup group: GroupEntity) async throws
    func fetchCards(forGroup group: GroupEntity) async throws -> [CardEntity]
    func cleanup() async throws
    func newCardEntity() -> CardEntity
    func newGroupEntity()-> GroupEntity
}
