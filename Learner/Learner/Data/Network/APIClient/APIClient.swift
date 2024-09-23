protocol APIClient {
    func performRequest<T: Decodable>(endpoint: String) async throws -> T
}