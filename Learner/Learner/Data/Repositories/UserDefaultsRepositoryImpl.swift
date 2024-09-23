//
//  UserDefaultsRepositoryImpl.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-09-19.
//

fileprivate let KEY_originURL:String = "KEY_originURL"
fileprivate let KEY_learnURL:String = "KEY_learnURL"

fileprivate let default_originURL:String = "https://raw.githubusercontent.com/andriitishchenko/CardsLearnerRepo/refs/heads/main"
fileprivate let default_learnURL:String = "https://raw.githubusercontent.com/andriitishchenko/CardsLearnerRepo/refs/heads/dutch"

import Foundation
class UserDefaultsRepositoryImpl: UserDefaultsRepository {
    private let userDefaults = UserDefaults.standard
    
    func saveUserSettings(_ settings: UserSettings) async throws {
        userDefaults.set(settings.originURL, forKey: KEY_originURL)
        userDefaults.set(settings.learnURL, forKey: KEY_learnURL)
    }
    
    func loadUserSettings() async throws -> UserSettings {
        let originURL = userDefaults.string(forKey: KEY_originURL) ?? default_originURL
        let learnURL = userDefaults.string(forKey: KEY_learnURL) ?? default_learnURL
        return UserSettings(originURL: originURL, learnURL: learnURL)
    }
}
