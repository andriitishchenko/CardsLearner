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

class SelectLanguageViewModel: ObservableObject {
    @Published var baseURL: String = ""
    @Published var translateURL: String = ""
    @Published var message: String = ""
    
    private var appIntent: AppIntent
    
    init(appIntent: AppIntent) {
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
            _ = try a_category?.isReachable()
            _ = try a_cards?.isReachable()
        }
        catch {
            throw RepoValidationError.invalidBaseURLJson
        }
        
        let b_cards = t_translateURL?.appendingPathComponent("cards.json", conformingTo: .url)
        do{
            _ = try b_cards?.isReachable()
        }
        catch{
            throw RepoValidationError.invalidLearnURLJson
        }
        
        await appIntent.updateUserSettings(origin: t_baseURL!.absoluteString, cards: t_translateURL!.absoluteString)
    }
    
    // Optionally load saved URLs when initializing
    func loadURLs() {
        Task { @MainActor in
            let upr: UserSettings = await appIntent.getUserSettings()!
                baseURL = upr.originURL
                translateURL = upr.learnURL
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
        Task {
            try await Task.sleep(for: .seconds(3))
            self.message = ""
        }
    }    
}
