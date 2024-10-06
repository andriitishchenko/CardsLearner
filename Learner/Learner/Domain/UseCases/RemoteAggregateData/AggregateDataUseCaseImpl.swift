//
//  AggregateDataUseCaseImpl.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-09-19.
//

import Foundation

class AggregateDataUseCaseImpl: AggregateDataUseCase {
    private let settings: UserSettings
    private let remoteRepository: RemoteDataRepository
    
    init(settings: UserSettings, remoteRepository: RemoteDataRepository) {
        self.settings = settings
        self.remoteRepository = remoteRepository
    }
    
    func execute() async throws -> [CategoryModel] {
        async let categoriesFetch = remoteRepository.fetchCategories(url: self.settings.originURL)
        async let originCardsFetch = remoteRepository.fetchCards(url: self.settings.originURL)
        async let learnCardsFetch = remoteRepository.fetchCards(url: self.settings.learnURL)
        
        do {
            let (categories, originCards, learnCards) = try await (categoriesFetch, originCardsFetch, learnCardsFetch)
            let langCode = categories.lang
            var modelCard = [ModelCard]()

            for item in originCards.list {
                if let lngCard = learnCards.list.first( where: { $0.id  == item.id }) {
                    let card = ModelCard(id: item.id,
                                         categoryId: item.categoryId,
                                         title: lngCard.title,
                                         translate: item.title,
                                         localCode: learnCards.lang,
                                         picture: item.picture,
                                         voice: lngCard.transcription,
                                         transcription: lngCard.transcription)
                                        
                    modelCard.append(card)
                }
            }
            
            var modlCategories = [CategoryModel]()
            for ct in categories.list {
                let list = modelCard.filter{ $0.categoryId == ct.id }
                let modelCategory = CategoryModel(id: ct.id, title: ct.title, picture: ct.picture, list: list)
                modlCategories.append(modelCategory)
            }
            return modlCategories
        } catch {
            throw error
        }
    }
}
