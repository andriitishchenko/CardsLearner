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

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Card data URL")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("https://example.com/language", text: $viewModel.baseURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textContentType(.URL)
                    }
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

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Learning language data URL")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("https://example.com/language", text: $viewModel.translateURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textContentType(.URL)
                    }
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
                    Label(viewModel.message, systemImage: "info.circle.fill")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                }
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                if let url = URL(string: "https://andriitishchenko.github.io/CardsLearnerRepo/") {
                    UIApplication.shared.open(url)
                }
            }) {
                Label("Help with language setup", systemImage: "questionmark.circle")
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.bordered)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
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
