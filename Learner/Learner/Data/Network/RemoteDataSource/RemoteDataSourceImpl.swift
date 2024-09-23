import Foundation

class RemoteDataSourceImpl: RemoteDataSource {
    func fetchCards(url: String) async throws -> CardResponse {
        let restClient = APIClientImpl()
        return try await restClient.performRequest(endpoint: "\(url)/cards.json")
    }
    
    func fetchCategories (url: String) async throws -> CategoryResponse {
        let restClient = APIClientImpl()
        return try await restClient.performRequest(endpoint: "\(url)/categories.json")
    }
}
