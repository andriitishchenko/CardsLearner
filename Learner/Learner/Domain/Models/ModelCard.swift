//
//  ModelCard.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-09-19.
//

import Foundation
struct ModelCard: Codable, Hashable {
    let id: Int
    let categoryId: Int
    let title: String
    var translate: String
    var localCode:String
    var picture: String?
    var voice: String?
    var transcription: String?
}
