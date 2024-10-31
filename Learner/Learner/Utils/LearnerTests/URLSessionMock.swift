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
class URLSessionMock: URLSessionProtocol {
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
        let response = self.response ?? HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (data ?? Data(), response)
    }
}
