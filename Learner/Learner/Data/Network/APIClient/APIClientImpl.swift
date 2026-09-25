import Foundation

final class APIClientImpl: APIClient {
    private let session: URLSessionProtocol
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func performRequest<T: Decodable>(endpoint: String) async throws -> T {
        guard let url = URL(string: endpoint),
              let scheme = url.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              url.host != nil else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.nonHTTPResponse
        }
        if !(200...299).contains(httpResponse.statusCode) {
            throw APIError.invalidResponse(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            return decodedResponse
        } catch {
            throw APIError.decodingError(error)
        }
    }
}

enum APIError: Error, LocalizedError, Equatable {
    static func == (lhs: APIError, rhs: APIError) -> Bool {
            switch (lhs, rhs) {
            case (.invalidResponse(let lhsCode), .invalidResponse(let rhsCode)):
                return lhsCode == rhsCode
            case (.decodingError, .decodingError):
                return true
            case (.nonHTTPResponse, .nonHTTPResponse):
                return true
            default:
                return false
            }
        }
    case invalidResponse(statusCode: Int)
    case nonHTTPResponse
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse(let statusCode):
            return "Received invalid response with status code \(statusCode)."
        case .nonHTTPResponse:
            return "Received a non-HTTP response."
        case .decodingError(let error):
            return "Failed to decode the response: \(error.localizedDescription)"
        }
    }
}
