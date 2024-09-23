//
//  LocalDataProcessingUseCaseImpl.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-09-19.
//

import Foundation

class LocalDataProcessingUseCaseImpl: LocalDataProcessingUseCase {
    
    let localRepository: LocalDataRepository
    
    init(localRepository: LocalDataRepository) {
        self.localRepository = localRepository
    }
    
    // Конвертация ModelCard в CardEntity
    func convertToCardEntity(from modelCard: ModelCard) -> CardEntity {
            let cardEntity = self.localRepository.newCardEntity()
            cardEntity.uid = Int32(modelCard.id)
            cardEntity.categoryId = Int32(modelCard.categoryId)
            cardEntity.title = modelCard.title
            cardEntity.imageURL = URL(string: modelCard.picture ?? "")
            cardEntity.voice = modelCard.voice
            cardEntity.transcription = modelCard.transcription
            cardEntity.translate = modelCard.translate
            cardEntity.lang = modelCard.localCode
            
            return cardEntity
    }

    // Конвертация CategoryModel в GroupEntity
    func convertToGroupEntity(from categoryModel: CategoryModel) -> GroupEntity {
        let groupEntity = self.localRepository.newGroupEntity()
        groupEntity.uid = Int32(categoryModel.id)
        groupEntity.title = categoryModel.title
        groupEntity.imageURL = URL(string: categoryModel.picture)
        
        let cards = categoryModel.list.map { convertToCardEntity(from: $0) }
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
            list: cards
        )
    }
    
    func executeSave(data:[CategoryModel]) async throws {
        let list = data.map{ convertToGroupEntity(from: $0) }
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
