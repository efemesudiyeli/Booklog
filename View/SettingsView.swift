//
//  SettingsView.swift
//  Booklog
//
//  Created by Efe Mesudiyeli on 8.12.2024.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    @ObservedObject var bookViewModel: BookViewModel
    @State private var readingGoal: Int = 30
    @State private var newGoal: String = ""
    @State private var nickname: String = ""
    @State private var newNickname: String = ""
    @State private var isUpdating: Bool = false

    
    let goalOptions: [Int] = Array(stride(from: 30, through: 300, by: 30))
    
    var body: some View {
        VStack {
            List {
                Section {
                    
                    Picker(selection: $readingGoal, label: Label("Reading Goal:", systemImage: "target")) {
                        ForEach(goalOptions, id: \.self) { goal in
                            Text("\(goal) minutes")
                        }
                    }
                    
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: readingGoal) { newValue in
                        bookViewModel.updateReadingGoal(newGoal: newValue)
                    }
                } header: {
                    Text("Personal Settings")
                }
                
                Section {
                    if let email = authViewModel.currentUser?.email {
                        Label("\(email)", systemImage: "person.circle")
                    }
                    
                    Button {
                        authViewModel.signOut()
                    } label: {
                        Label("Log out", systemImage: "iphone.and.arrow.right.outward")
                    }
                    
                    HStack {
                        Label("Name", systemImage: "person.text.rectangle")
                        
                        Spacer()
                        
                        TextField(nickname, text: $newNickname)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 150)
                            .onSubmit {
                                print("Nickname submitted: \(newNickname)")
                            }
                        
                        Button(action: {
                            guard !newNickname.isEmpty, !isUpdating else { return }
                            isUpdating = true
                
                            authViewModel.updateNickname(newNickname: newNickname) { error in
                                isUpdating = false
                                if let error = error {
                                    print("Error updating nickname: \(error.localizedDescription)")
                                } else {
                                    nickname = newNickname
                                    newNickname = ""
                                }
                            }
                        }) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                        }
                        .buttonStyle(BorderlessButtonStyle()) 
                    }
                } header: {
                    Text("User Settings")
                }
            }
        }
    }
}

#Preview {
    SettingsView(
        authViewModel: AuthenticationViewModel(isAuthenticated: true),
        bookViewModel: BookViewModel()
    )
}
