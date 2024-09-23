//
//  Errors.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-09-19.
//

import Foundation
enum CustomError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidData
    case serverError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .invalidResponse:
            return "The server response was invalid."
        case .invalidData:
            return "The data received from the server was invalid."
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        }
    }
}
