//
//  LocalDataProcessingUseCaseImpl.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-09-19.
//

import Foundation

enum LocalDataProcessingError: LocalizedError {
    case integerOutOfRange

    var errorDescription: String? {
        "A card or category identifier is outside the supported storage range."
    }
}

@MainActor
final class LocalDataProcessingUseCaseImpl: LocalDataProcessingUseCase {
    
    let localRepository: LocalDataRepository
    
    init(localRepository: LocalDataRepository) {
        self.localRepository = localRepository
    }

    func validate(data: [CategoryModel]) throws {
        for category in data {
            guard Int32(exactly: category.id) != nil,
                  Int32(exactly: category.order) != nil else {
                throw LocalDataProcessingError.integerOutOfRange
            }
            for card in category.list {
                guard Int32(exactly: card.id) != nil,
                      Int32(exactly: card.categoryId) != nil else {
                    throw LocalDataProcessingError.integerOutOfRange
                }
            }
        }
    }
    
    // Конвертация ModelCard в CardEntity
    func convertToCardEntity(from modelCard: ModelCard) throws -> CardEntity {
            guard let uid = Int32(exactly: modelCard.id),
                  let categoryId = Int32(exactly: modelCard.categoryId) else {
                throw LocalDataProcessingError.integerOutOfRange
            }
            let cardEntity = self.localRepository.newCardEntity()
            cardEntity.uid = uid
            cardEntity.categoryId = categoryId
            cardEntity.title = modelCard.title
            cardEntity.imageURL = URL(string: modelCard.picture ?? "")
            cardEntity.voice = modelCard.voice
            cardEntity.transcription = modelCard.transcription
            cardEntity.translate = modelCard.translate
            cardEntity.lang = modelCard.localCode
            
            return cardEntity
    }

    // Конвертация CategoryModel в GroupEntity
    func convertToGroupEntity(from categoryModel: CategoryModel) throws -> GroupEntity {
        guard let uid = Int32(exactly: categoryModel.id),
              let order = Int32(exactly: categoryModel.order) else {
            throw LocalDataProcessingError.integerOutOfRange
        }
        let groupEntity = self.localRepository.newGroupEntity()
        groupEntity.uid = uid
        groupEntity.order = order
        groupEntity.title = categoryModel.title
        groupEntity.imageURL = URL(string: categoryModel.picture)
        
        let cards = try categoryModel.list.map { try convertToCardEntity(from: $0) }
        groupEntity.addToCards(NSSet(array: cards))
        
        return groupEntity
    }
    
    // Конвертация CardEntity в ModelCard
    func convertToModelCard(from cardEntity: CardEntity) -> ModelCard {
        return ModelCard(
            id: Int(cardEntity.uid),
            categoryId: Int(cardEntity.categoryId),
            title: cardEntity.title ?? "",
            translate: cardEntity.translate ?? "",
            localCode: cardEntity.lang ?? "",
            picture: cardEntity.imageURL?.absoluteString,
            voice: cardEntity.voice,
            transcription: cardEntity.transcription
        )
    }

    // Конвертация GroupEntity в CategoryModel
    func convertToCategoryModel(from groupEntity: GroupEntity) -> CategoryModel {
        // Преобразуем NSSet с карточками в массив ModelCard
        let cards: [ModelCard]
        if let cardEntities = groupEntity.cards as? Set<CardEntity> {
            cards = cardEntities.map { convertToModelCard(from: $0) }
        } else {
            cards = []
        }
        
        return CategoryModel(
            id: Int(groupEntity.uid),
            title: groupEntity.title ?? "",
            picture: groupEntity.imageURL?.absoluteString ?? "",
            order: Int(groupEntity.order),
            list: cards
        )
    }
    
    func executeSave(data:[CategoryModel]) async throws {
        let list = try data.map { try convertToGroupEntity(from: $0) }
        try await self.localRepository.saveGroups(list)
    }
    
    func executeLoad() async throws -> [CategoryModel] {
        let list = try await self.localRepository.fetchGroups()
        let result:[CategoryModel] = list.map{ convertToCategoryModel(from: $0) }
        return result
    }
    
    func cleanup() async throws {
        try await self.localRepository.cleanup()
    }
}
