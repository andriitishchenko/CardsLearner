//
//  MockAppIntentPreview.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-09-19.
//

import Foundation

class MockAppIntent: Intent {
    @Published var errorMessage: String?
    @Published var list: [CategoryModel]?
    
    func updateUserSettings(origin: String, cards: String) {}
    var listPublisher: Published<[CategoryModel]?>.Publisher { $list }
    
    func getUserSettings() async -> UserSettings? {
        return nil
    }
    
     init() {
        self.list = [
            CategoryModel(
                id: 1,
                title: "Category 1",
                picture: "https://example.com/category1.png",
                list: [
                    ModelCard(id: 1, categoryId: 1, title: "Card 1", translate: "Translation 1", localCode: "en", picture: "https://loremflickr.com/640/480/family", voice: "", transcription: "[card 1]"),
                    ModelCard(id: 2, categoryId: 1,title: "Card 2", translate: "Translation 2", localCode: "en", picture: "https://loremflickr.com/640/480/family", voice: "", transcription: "[card 2]")
                ]
            ),
            CategoryModel(
                id: 2,
                title: "Category 2",
                picture: "https://example.com/category2.png",
                list: [
                    ModelCard(id: 3,categoryId: 2, title: "Card 3", translate: "Translation 3", localCode: "en", picture: "https://loremflickr.com/640/480/family", voice: "", transcription: "[card 3]"),
                    ModelCard(id: 4,categoryId: 2, title: "Card 4", translate: "Translation 4", localCode: "en", picture: "https://loremflickr.com/640/480/family", voice: "", transcription: "[card 4]")
                ]
            )
        ]
    }
}
