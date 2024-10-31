//
//  APIClientTests.swift
//  LearnerTests
//
//  Created by Andrii Tishchenko on 2024-09-19.
//


import Foundation
import XCTest

@testable import Learner

class APIClientTests: XCTestCase {
    
    var apiClient: APIClientImpl!
    var mockURLSession: URLSessionMock!
    
    override func setUp() {
        super.setUp()
        mockURLSession = URLSessionMock()
        apiClient = APIClientImpl(session: mockURLSession)
    }
    
    override func tearDown() {
        mockURLSession = nil
        apiClient = nil
        super.tearDown()
    }
    
    func testPerformRequestSuccess() async throws {
        // Подготавливаем тестовые данные
        let testData = """
        {
            "id": 1,
            "title": "Test Title"
        }
        """.data(using: .utf8)!
        
        // Настраиваем mock сессию на возврат этих данных
        mockURLSession.data = testData
        
        // Модель, которую ожидаем получить
        struct TestResponse: Decodable {
            let id: Int
            let title: String
        }
        
        // Выполняем запрос и проверяем результат
        let response: TestResponse = try await apiClient.performRequest(endpoint: "https://example.com/test")
        
        XCTAssertEqual(response.id, 1)
        XCTAssertEqual(response.title, "Test Title")
    }
    
    func testPerformRequestInvalidStatusCode() async throws {
        // Подготавливаем mock данные с неудачным статусом
        mockURLSession.data = Data() // Пустой ответ
        mockURLSession.response = HTTPURLResponse(url: URL(string: "https://example.com")!,
                                                  statusCode: 500,
                                                  httpVersion: nil,
                                                  headerFields: nil)
        
        do {
            let _: String = try await apiClient.performRequest(endpoint: "https://example.com/test")
            XCTFail("Expected APIError.invalidResponse to be thrown")
        } catch {
            XCTAssertEqual(error as? APIError, APIError.invalidResponse(statusCode: 500))
        }
    }
    
    func testPerformRequestDecodingError() async throws {
        // Подготавливаем некорректные данные для декодирования
        let invalidData = "invalid data".data(using: .utf8)!
        mockURLSession.data = invalidData
        
        do {
            let _: String = try await apiClient.performRequest(endpoint: "https://example.com/test")
            XCTFail("Expected APIError.decodingError to be thrown")
        } catch {
            if case APIError.decodingError(let decodingError) = error {
                XCTAssertTrue(decodingError is DecodingError)
            } else {
                XCTFail("Expected decodingError to be thrown")
            }
        }
    }
}
