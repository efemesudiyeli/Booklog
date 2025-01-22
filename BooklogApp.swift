//
//  BooklogApp.swift
//  Booklog
//
//  Created by Efe Mesudiyeli on 23.11.2024.
//

import SwiftUI
import Firebase

@main
struct BooklogApp: App {
    @StateObject private var authViewModel = AuthenticationViewModel()
    @StateObject private var bookViewModel = BookViewModel()

    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            
                if authViewModel.isAuthenticated {
                    MainView(authViewModel: authViewModel, bookViewModel: bookViewModel)
                } else {
                    NavigationStack {
                        LoginView(authViewModel: authViewModel)
                    }
                }
            
        }
    }
}

