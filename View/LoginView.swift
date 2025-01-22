import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @ObservedObject var authViewModel: AuthenticationViewModel
    @State private var loginError: String?
    @State private var showEmailEmptyError: Bool = false
    @State private var showPasswordEmptyError: Bool = false
    
    
    
    var body: some View {
        VStack {
            
            VStack {
                Text("Booklog")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                    .foregroundStyle(Color.cPrimary)
                Text("Develop yourself.")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.cPrimary)
            }
            
          
            
            ZStack {
            
                UnevenRoundedRectangle(
                    topLeadingRadius: 100,
                    bottomLeadingRadius: 100,
                    bottomTrailingRadius: 15,
                    topTrailingRadius: 15
                    
                )
                .fill(Color.cSecondary)
                .scaleEffect(0.90)
                
                
                VStack {
                    
                    Spacer()
                    
                    if #available(iOS 17.0, *) {
                        TextField(
                            "",
                            text: $email,
                            prompt: Text("Email")
                                .foregroundStyle(.white.opacity(0.5))
                        )
                        .textFieldStyle(
                            CustomTextFieldStyle(iconName: "envelope.fill")
                        )
                        .keyboardType(.emailAddress)
                        .frame(maxWidth: 350)
                        .autocapitalization(.none)
                        
                    } else {
                        TextField(
                            "",
                            text: $email,
                            prompt: Text("Email")
                                .foregroundColor(.white.opacity(0.5))
                        )
                        .textFieldStyle(
                            CustomTextFieldStyle(iconName: "envelope.fill")
                        )
                        .keyboardType(.emailAddress)
                        .frame(maxWidth: 350)
                        .autocapitalization(.none)
                    }
                    
                    if showEmailEmptyError {
                        Text("Email cannot be empty!")
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .padding(.vertical, 10)
                    }
                    
                    if #available(iOS 17.0, *) {
                        SecureField(
                            "",
                            text: $password,
                            prompt: Text("Password")
                                .foregroundStyle(.white.opacity(0.5))
                        )
                        .textFieldStyle(
                            CustomTextFieldStyle(iconName: "lock.fill")
                        )
                        .frame(maxWidth: 350)
                    } else {
                        SecureField(
                            "",
                            text: $password,
                            prompt: Text("Password")
                                .foregroundColor(.white.opacity(0.5))
                        )
                        .textFieldStyle(
                            CustomTextFieldStyle(iconName: "lock.fill")
                        )
                        .frame(maxWidth: 350)
                    }
                    
                    if showPasswordEmptyError {
                        Text("Password cannot be empty!")
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .padding(.vertical, 10)
                    }
                    if let error = loginError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .padding(.vertical, 10)
                    }
                    
                    VStack(spacing: 20) {
                        Button(action: {
                            if email.isEmpty {
                                showEmailEmptyError = true
                            } else {
                                showEmailEmptyError = false
                            }
                            
                            if password.isEmpty {
                                showPasswordEmptyError = true
                            } else {
                                showPasswordEmptyError = false
                            }
                            
                            if !email.isEmpty && !password.isEmpty {
                                authViewModel.signIn(email: email, password: password) { error in
                                    if let error = error {
                                        self.loginError = authViewModel.getErrorMessage(error)
                                    } else {
                                        self.loginError = nil
                                    }
                                }
                            }
                        }) {
                            Text("Log in")
                                .frame(maxWidth: .infinity, maxHeight:  50)
                                .background(Color.cAccent)
                                .foregroundColor(.cPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        
                        VStack(spacing: 6) { // Sosyal giriş butonları
                            Button {
                                // Apple action
                            } label: {
                                HStack {
                                    Image(systemName: "applelogo")
                                    Text("Continue with Apple")
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Color.cBackground)
                            .foregroundColor(.cPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            Button {
                                // Google action
                            } label: {
                                HStack {
                                    Image(systemName: "g.circle.fill")
                                    Text("Continue with Google")
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Color.cBackground)
                            .foregroundColor(.cPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }.padding(.horizontal, 20)
                    
                    
                    
                    Spacer()
                    
                }
                .padding()
                
              

            }
            
        
            
            NavigationLink {
                SignupView(authViewModel: authViewModel)
            } label: {
                Text("Don't have any account? Sign Up")
                    .font(.title3)
                    .foregroundStyle(Color.cAccent)
            }
            
        }.background(Color.cBackground)
            .navigationBarBackButtonHidden()
        
    }
}

#Preview {
    LoginView(authViewModel: AuthenticationViewModel(isAuthenticated: true))
}
