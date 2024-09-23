//
//  Models.swift
//  CardsLearner
//
//  Created by Andrii Tishchenko on 2024-09-14.
//

import Foundation

struct RestCard: Codable {
    let id: Int
    let categoryId: Int
    let title: String
    var picture: String?
    var voice: String?
    var transcription: String?
}

struct RestCategory: Codable {
    let id:Int
    let order:Int
    let title: String
    let picture: String
}

struct CategoryResponse: Codable {
    let lang: String
    let version: Int
    let list: [RestCategory]
}

struct CardResponse: Codable {
    let version: Int
    let lang: String
    let list: [RestCard]
}
