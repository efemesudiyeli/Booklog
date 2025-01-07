//
//  MainView.swift
//  Booklog
//
//  Created by Efe Mesudiyeli on 23.11.2024.
//

import SwiftUI
import FirebaseAuth

struct MainView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    @ObservedObject var bookViewModel: BookViewModel
    
    
    var body: some View {
        TabView {
            HomeView(
                authViewModel: authViewModel,
                bookViewModel: bookViewModel
            )
            .tabItem {
                Image(systemName: "house")
            }
            SearchBookView(bookViewModel: bookViewModel)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                }
            SessionView(bookViewModel: bookViewModel)
                .tabItem {
                    Image(systemName: "play")
                }
            BookListView(viewModel: bookViewModel)
                .tabItem {
                    Image(systemName: "books.vertical")
                }
            SettingsView(
                authViewModel: authViewModel,
                bookViewModel: bookViewModel
            )
            .tabItem {
                Image(systemName: "gearshape")
            }
        }
    }
}

#Preview {
    MainView(authViewModel: AuthenticationViewModel(isAuthenticated: true), bookViewModel: BookViewModel())
}
