//
//  URLSessionMock.swift
//  LearnerTests
//
//  Created by Andrii Tishchenko on 2024-09-19.
//

import Foundation
@testable import Learner

//// Протокол URLSessionProtocol для инъекции зависимости
//protocol URLSessionProtocol {
//    func data(from url: URL) async throws -> (Data, URLResponse)
//}

// Мок-класс для URLSession для использования в тестах
// Tests configure this mock before each request and do not mutate it while a request is running.
final class URLSessionMock: URLSessionProtocol, @unchecked Sendable {
    var data: Data?
    var error: Error?
    var response: URLResponse?

    // Метод для симуляции выполнения запроса
    func data(from url: URL) async throws -> (Data, URLResponse) {
        // Если установлена ошибка, выбрасываем её
        if let error = error {
            throw error
        }
        
        // Возвращаем данные и ответ (или создаём дефолтный ответ, если он не задан)
        let response: URLResponse
        if let configuredResponse = self.response {
            response = configuredResponse
        } else if let defaultResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) {
            response = defaultResponse
        } else {
            throw URLError(.badServerResponse)
        }
        return (data ?? Data(), response)
    }
}
