//
//  AggregateDataUseCase.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-09-19.
//

import Foundation

protocol AggregateDataUseCase {
    func execute() async throws -> [CategoryModel]
}
