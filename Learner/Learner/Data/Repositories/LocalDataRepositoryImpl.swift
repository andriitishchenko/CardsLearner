import Foundation

class LocalDataRepositoryImpl: LocalDataRepository {
    func newCardEntity() -> CardEntity {
        return self.localDataSource.newCardEntity()
    }
    
    func newGroupEntity() -> GroupEntity {
        return self.localDataSource.newGroupEntity()
    }
    
    private let localDataSource: any LocalDataSource
    
    init(localDataSource: any LocalDataSource) {
        self.localDataSource = localDataSource
    }

    func saveGroup(_ group: GroupEntity) async throws {
        try await self.localDataSource.saveGroup(group)
    }
    
    func saveGroups(_ groups: [GroupEntity]) async throws{
        try await self.localDataSource.saveGroups(groups)
    }
    
    func fetchGroups() async throws -> [GroupEntity] {
        return try await self.localDataSource.fetchGroups()
    }
    
    func saveCard(_ card: CardEntity, toGroup group: GroupEntity) async throws {
        try await self.localDataSource.saveCard(card, toGroup: group)
    }
    
    func fetchCards(forGroup group: GroupEntity) async throws -> [CardEntity] {
        return try await self.localDataSource.fetchCards(forGroup: group)
    }
    
    func cleanup() async throws {
        try await self.localDataSource.cleanup()
    }
}
