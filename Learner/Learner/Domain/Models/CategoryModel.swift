//
//  AgregatedData.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-09-19.
//

import Foundation

struct CategoryModel: Codable, Equatable, Hashable {
    static func == (lhs: CategoryModel, rhs: CategoryModel) -> Bool {
        return lhs.title == rhs.title
    }
    let id: Int
    let title: String
    let picture: String
    let list: [ModelCard]
}
