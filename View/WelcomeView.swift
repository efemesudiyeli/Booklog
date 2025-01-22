//
//  WelcomeView.swift
//  Booklog
//
//  Created by Efe Mesudiyeli on 22.01.2025.
//
import SwiftUI


struct WelcomeView: View {
    @State private var nickname: String = "Loading..."
    @State private var randomWelcomeMessage: String = "Welcome,"
    @ObservedObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Booklog")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.cPrimary)
                .padding(.top)
            
            HStack {
                Text(randomWelcomeMessage)
                Text(nickname).bold() + Text("!")
                    .font(.title3)
                    .fontWeight(.light)
                    .foregroundColor(.primary)
            }
        }
        .onAppear {
            randomWelcomeMessage = WelcomeMessages.messages.randomElement() ?? "Welcome,"

            authViewModel.fetchNickname { fetchedNickname in
                if let fetchedNickname = fetchedNickname {
                    nickname = "\(fetchedNickname)"
                } else {
                    nickname = "Guest"
                }
            }
        }
    }
}
