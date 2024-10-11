//
//  LearnerApp.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-09-18.
//

import SwiftUI
import Combine
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}


@main
struct LearnerApp: App {
    private let appIntent: AppIntent
    @State private var scale: CGFloat = 0.5
    
    @State private var displayedMessage: String?
    @State private var isLoading: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        let persistenceController = PersistenceController.shared
        let localDataSource = LocalDataSourceImpl(context: persistenceController.container.viewContext)
        let remoteDataSource = RemoteDataSourceImpl()
        self.appIntent = AppIntent(localDatasource: localDataSource, remoteDatasource: remoteDataSource)
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                MainView(appIntent: appIntent)                
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .green))
                        .frame(width: 100, height: 100) // Adjusted size
                        .background(Color.white.opacity(0.8)) // Slightly less opacity for better visibility
                        .cornerRadius(15)
                        .shadow(radius: 10)
                        .padding()
                        .scaleEffect(scale)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.8)) {
                                scale = 1.2
                            }
                        }
                }
                
                if let errorMessage = displayedMessage, !errorMessage.isEmpty {
                    VStack {
                        ErrorPopupView(message: errorMessage)
                            .transition(.scale) // More appropriate transition for the popup
                            .onTapGesture {
                                Task {
                                    displayedMessage = ""
                                }
                            }
                        Spacer()
                    }
                }
                
            }
            .onReceive(appIntent.$errorMessage) { newMessage in
                            displayedMessage = newMessage
            }
            .onReceive(appIntent.$isLoading) { val in
                isLoading = val
            }
        }
        
    }
    
}
