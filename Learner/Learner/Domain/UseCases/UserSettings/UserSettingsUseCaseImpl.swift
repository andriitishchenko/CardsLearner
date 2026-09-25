//
//  SaveUserSettingsUseCaseImpl.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-09-19.
//

import Foundation
@MainActor
final class UserSettingsUseCaseImpl: UserSettingsUseCase {
    
    private let userDefaultsRepository: UserDefaultsRepository
    
    init(userDefaultsRepository: UserDefaultsRepository) {
        self.userDefaultsRepository = userDefaultsRepository
    }
    
    func executeSave(settings: UserSettings) async throws {
        try await userDefaultsRepository.saveUserSettings(settings)
    }
    
    func executeLoad() async throws -> UserSettings {
        return try await userDefaultsRepository.loadUserSettings()
    }
}
