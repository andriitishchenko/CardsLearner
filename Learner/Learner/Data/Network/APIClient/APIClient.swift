protocol APIClient: Sendable {
    func performRequest<T: Decodable>(endpoint: String) async throws -> T
}
