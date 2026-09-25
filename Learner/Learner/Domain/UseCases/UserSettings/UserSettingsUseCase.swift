//
//  SaveUserSettingsUseCase.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-09-19.
//

import Foundation

@MainActor
protocol UserSettingsUseCase {
    func executeSave(settings: UserSettings) async throws
    func executeLoad() async throws -> UserSettings
}
