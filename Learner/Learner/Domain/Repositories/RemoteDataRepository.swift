//
//  FetchLearnURLData.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-09-19.
//

import Foundation

protocol RemoteDataRepository {
    func fetchCards(url:String)  async throws -> CardResponse
    func fetchCategories(url:String) async throws -> CategoryResponse
}
