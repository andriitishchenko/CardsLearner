//
//  SelectLanguageScreen.swift
//  CardsLearner
//
//  Created by Andrii Tishchenko on 2024-09-16.
//

import SwiftUI

struct SelectLanguageScreen: View {
    @ObservedObject var viewModel: SelectLanguageViewModel
    
    var body: some View {
        VStack {
            Form {
                // Dropdown for "Language you speak"
                Section(header: Text("Language you speak")) {
                    Picker(selection: $viewModel.selectedBaseLanguage, label: Text("Select language")) {
                        ForEach(viewModel.languages, id: \.self) { language in
                            Text("\(language.flag) \(language.name)")
                            .tag(language)
                        }
                    }
                    .onChange(of: viewModel.selectedBaseLanguage) { newValue in
                        viewModel.baseURL = newValue.url // Update the text field with the selected URL
                    }

                    TextField("Enter URL for cards", text: $viewModel.baseURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textContentType(.URL)
                }

                // Dropdown for "Language you learn"
                Section(header: Text("Language you learn")) {
                    Picker(selection: $viewModel.selectedLearnLanguage, label: Text("Select language")) {
                        ForEach(viewModel.languages, id: \.self) { language in
                            Text("\(language.flag) \(language.name)")
                            .tag(language)
                            .clipped()
                        }
                    }
                    .onChange(of: viewModel.selectedLearnLanguage) { newValue in
                        viewModel.translateURL = newValue.url // Update the text field with the selected URL
                    }

                    TextField("Enter URL for learning", text: $viewModel.translateURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textContentType(.URL)
                }

                // Save button
                Button(action: {
                    viewModel.onSaveClick()
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.baseURL.isEmpty || viewModel.translateURL.isEmpty)
                
                if !viewModel.message.isEmpty {
                    Text(viewModel.message)
                }
            }
            
            Spacer()
            
            // Help button
            Button(action: {
                if let url = URL(string: "https://andriitishchenko.github.io/CardsLearnerRepo/") {
                    UIApplication.shared.open(url)
                }
            }) {
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 60, height: 60)
                    Text("?")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
            }
        }
        .navigationTitle("Select Language")
        .onAppear {
            viewModel.loadURLs()  // Load saved URLs when screen appears
        }
    }
}

//
//#Preview {
//    let intent = MockAppIntent()
//    let vm  = SelectLanguageViewModel(appIntent: intent)
//    return SelectLanguageScreen(viewModel: vm)
//}
