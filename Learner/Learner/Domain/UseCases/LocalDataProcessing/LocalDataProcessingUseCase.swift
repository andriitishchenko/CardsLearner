//
//  LocalDataProcessingUseCase.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-09-19.
//

import Foundation

protocol LocalDataProcessingUseCase{
    func executeSave(data:[CategoryModel]) async throws
    func executeLoad() async throws -> [CategoryModel]
    func cleanup() async throws
}
