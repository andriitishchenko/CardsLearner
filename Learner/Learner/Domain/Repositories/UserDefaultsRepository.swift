//
//  UserDefaultsRepository.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-09-19.
//

import Foundation
protocol UserDefaultsRepository {
    func saveUserSettings(_ settings: UserSettings) async throws
    func loadUserSettings() async throws -> UserSettings
}
