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
    func isReachable() throws -> Bool {
        var request = URLRequest(url: self)
        request.httpMethod = "HEAD"
        
        let semaphore = DispatchSemaphore(value: 0) // To make the request synchronous
        var isReachable = false
        var requestError: Error?

        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                requestError = error
            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                isReachable = true
            }
            semaphore.signal()
        }
        task.resume()
        
        // Wait for the network request to finish
        semaphore.wait()
        
        if let error = requestError {
            throw error
        }
        
        guard isReachable else {
            throw URLReachabilityError.unreachable
        }
        
        return isReachable
    }
}
