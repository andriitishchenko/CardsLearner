protocol RemoteDataSource: Sendable {
    func fetchCards(url:String)  async throws -> CardResponse
    func fetchCategories(url:String) async throws -> CategoryResponse
}
