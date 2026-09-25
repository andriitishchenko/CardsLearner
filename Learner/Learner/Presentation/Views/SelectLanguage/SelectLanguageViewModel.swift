//
//  SelectLanguageViewModel.swift
//  CardsLearner
//
//  Created by Andrii Tishchenko on 2024-09-16.
//

import Foundation
import SwiftUI

enum RepoValidationError: Error {
    case invalidBaseURLJson
    case invalidLearnURLJson
}

struct Language: Hashable {
    let name: String
    let flag: String
    let url: String
}

@MainActor
final class SelectLanguageViewModel: ObservableObject {
    @Published var baseURL: String = ""
    @Published var translateURL: String = ""
    @Published var message: String = ""
    
    // Selected languages
    @Published var selectedBaseLanguage: Language
    @Published var selectedLearnLanguage: Language
    
    let languages: [Language] = [
        Language(name: "English", flag: "🇬🇧", url: "https://raw.githubusercontent.com/andriitishchenko/CardsLearnerRepo/refs/heads/main"),
        Language(name: "Dutch", flag: "🇳🇱", url: "https://raw.githubusercontent.com/andriitishchenko/CardsLearnerRepo/refs/heads/dutch"),
        Language(name: "Українська мова", flag: "🇺🇦", url: "https://raw.githubusercontent.com/andriitishchenko/CardsLearnerRepo/refs/heads/ua"),
        Language(name: "Polski", flag: "🇵🇱", url: "https://raw.githubusercontent.com/andriitishchenko/CardsLearnerRepo/refs/heads/pl"),
        Language(name: "Español", flag: "🇪🇸", url: "https://raw.githubusercontent.com/andriitishchenko/CardsLearnerRepo/refs/heads/es"),
        Language(name: "Français", flag: "🇫🇷", url: "https://raw.githubusercontent.com/andriitishchenko/CardsLearnerRepo/refs/heads/fr"),
        Language(name: "Deutsch", flag: "🇩🇪", url: "https://raw.githubusercontent.com/andriitishchenko/CardsLearnerRepo/refs/heads/de"),
        Language(name: "Italiano", flag: "🇮🇹", url: "https://raw.githubusercontent.com/andriitishchenko/CardsLearnerRepo/refs/heads/it"),
        Language(name: "Русский язык", flag: "🇷🇺", url: "https://raw.githubusercontent.com/andriitishchenko/CardsLearnerRepo/refs/heads/ru"),
        Language(name: "", flag: "⚙", url: "")
    ]
    
    private var appIntent: AppIntent
    private var clearMessageTask: Task<Void, Never>?
    
    init(appIntent: AppIntent) {
        selectedBaseLanguage = languages[0]
        selectedLearnLanguage = languages[1]
        self.appIntent = appIntent
        self.loadURLs()
    }
    
    // Logic to save URLs (for example, to UserDefaults)
    func saveURLs() async throws {
        
        let t_baseURL = URL(string: baseURL)
        let t_translateURL = URL(string: translateURL)
        
        let a_category = t_baseURL?.appendingPathComponent("categories.json", conformingTo: .url)
        let a_cards = t_baseURL?.appendingPathComponent("cards.json", conformingTo: .url)
        do{
            guard let a_category, let a_cards else {
                throw RepoValidationError.invalidBaseURLJson
            }
            _ = try await a_category.isReachable()
            _ = try await a_cards.isReachable()
        }
        catch {
            throw RepoValidationError.invalidBaseURLJson
        }
        
        let b_cards = t_translateURL?.appendingPathComponent("cards.json", conformingTo: .url)
        do{
            guard let b_cards else {
                throw RepoValidationError.invalidLearnURLJson
            }
            _ = try await b_cards.isReachable()
        }
        catch{
            throw RepoValidationError.invalidLearnURLJson
        }
        
        guard let t_baseURL, let t_translateURL else {
            throw RepoValidationError.invalidBaseURLJson
        }
        appIntent.updateUserSettings(origin: t_baseURL.absoluteString, cards: t_translateURL.absoluteString)
    }
    
    // Optionally load saved URLs when initializing
    func loadURLs() {
        Task { @MainActor in
            guard let upr = await appIntent.getUserSettings() else { return }
                baseURL = upr.originURL
                translateURL = upr.learnURL
            
            selectedBaseLanguage = languages.first(where: {
                return $0.url == baseURL
            }) ?? languages[languages.count - 1]
            
            selectedLearnLanguage = languages.first(where: {
                return $0.url == translateURL
            }) ?? languages[languages.count - 1]
            
        }
    }

    func onSaveClick(){
        Task {
            do{
                try await saveURLs()
                await showMessage("Saved")
            }
            catch{
                var str = ""
                switch(error){
                    case RepoValidationError.invalidBaseURLJson: str  = "Categories and cards files are not available for 1 url"
                    case RepoValidationError.invalidLearnURLJson: str = "Categories and cards files are not available for 2 url"
                    default:
                        str = error.localizedDescription
                    }
                await showMessage(str)
            }
            
        }
    }
    
    @MainActor
    func showMessage(_ str:String) async{
        message = str
        clearMessageTask?.cancel()
        clearMessageTask = Task { @MainActor [weak self] in
            do {
                try await Task.sleep(for: .seconds(3))
            } catch {
                return
            }
            self?.message = ""
        }
    }    
}
