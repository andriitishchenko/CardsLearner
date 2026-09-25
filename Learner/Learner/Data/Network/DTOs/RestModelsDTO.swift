//
//  Models.swift
//  CardsLearner
//
//  Created by Andrii Tishchenko on 2024-09-14.
//

import Foundation

struct RestCard: Codable, Sendable {
    let id: Int
    let categoryId: Int
    let title: String
    var picture: String?
    var voice: String?
    var transcription: String?
}

struct RestCategory: Codable, Sendable {
    let id:Int
    let order:Int
    let title: String
    let picture: String
}

struct CategoryResponse: Codable, Sendable {
    let lang: String
    let version: Int
    let list: [RestCategory]
}

struct CardResponse: Codable, Sendable {
    let version: Int
    let lang: String
    let list: [RestCard]
}
