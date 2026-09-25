//
//  URL+isReachable.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-10-11.
//

import Foundation

enum URLReachabilityError: Error {
    case unreachable
    case invalidResponse
}

extension URL {
    func isReachable() async throws -> Bool {
        var request = URLRequest(url: self)
        request.httpMethod = "HEAD"

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLReachabilityError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLReachabilityError.unreachable
        }
        return true
    }
}
