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
        VStack{
            Form {
                Section(header: Text("Language you speak")) {
                    TextField("Enter URL for cards", text: $viewModel.baseURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textContentType(.URL)
                }
                
                Section(header: Text("Language you learn")) {
                    TextField("Enter URL for learning", text: $viewModel.translateURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textContentType(.URL)
                }
                
                Button(action: {
                    viewModel.onSaveClick()
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.baseURL.isEmpty || viewModel.translateURL.isEmpty)
                
                if !viewModel.message.isEmpty{
                    Text(viewModel.message)
                    
                }
            }
            Spacer()
            Button(action: {
                        // Handle help button action here
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
