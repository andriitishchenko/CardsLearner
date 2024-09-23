//
//  FetchLearnURLDataImpl.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-09-19.
//

import Foundation

class RemoteDataRepositoryImpl: RemoteDataRepository{
    private let remoteDataSource: any RemoteDataSource
    
    init(remoteDataSource: any RemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }
    
    func fetchCards(url: String) async throws -> CardResponse {
        return try await remoteDataSource.fetchCards(url: url)
    }
    
    func fetchCategories (url: String) async throws -> CategoryResponse {
        return try await remoteDataSource.fetchCategories(url: url)
    }
    
    
}
