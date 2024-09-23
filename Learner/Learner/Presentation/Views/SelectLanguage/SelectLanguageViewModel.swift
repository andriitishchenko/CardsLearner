//
//  SelectLanguageViewModel.swift
//  CardsLearner
//
//  Created by Andrii Tishchenko on 2024-09-16.
//

import Foundation
import SwiftUI

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
    func saveURLs() async {
        if baseURL.isEmpty || baseURL.isEmpty {
            await showMessage("invalid url")
            return
        }
        await appIntent.updateUserSettings(origin: baseURL, cards: translateURL)
    }
    
    // Optionally load saved URLs when initializing
    func loadURLs() {
        Task { @MainActor in
            let upr: UserSettings = await appIntent.getUserSettings()!
            await MainActor.run {
                baseURL = upr.originURL
                translateURL = upr.learnURL
            }
        }
    }

    func onSaveClick(){
        Task {
            await saveURLs()
            await showMessage("Saved")
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
