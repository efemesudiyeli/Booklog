import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @ObservedObject var authViewModel: AuthenticationViewModel
    @State private var loginError: String?
    @State private var showEmailEmptyError: Bool = false
    @State private var showPasswordEmptyError: Bool = false


    
    var body: some View {
        VStack(spacing: 100) {
            VStack {
                Text("Booklog")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                    .foregroundStyle(Color.background)
                Text("Develop yourself.")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.background)
            }
            
            ZStack {
                UnevenRoundedRectangle(topLeadingRadius: 100).fill(Color.background)
                    
                VStack {
                   
                    Spacer()
                    
                    TextField("E-mail", text: $email)
                        .textFieldStyle(CustomTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .frame(maxWidth: 350)

                    if showEmailEmptyError {
                        Text("Email cannot be empty!")
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .padding(.vertical, 10)
                    }

                    SecureField("Password", text: $password)
                        .textFieldStyle(CustomTextFieldStyle())
                        .frame(maxWidth: 350)

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
                            .frame(maxWidth: 350)
                            .padding(.vertical)
                            .background(Color.foreground)
                            .foregroundColor(.background)
                            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 10, bottomLeadingRadius: 10, bottomTrailingRadius: 10))
                            .font(.headline)
                    }

                    
                    
                    
                    VStack {
                        Button(action: {
                        }) {
                            HStack {
                                Image(systemName: "applelogo")
                                    .font(.title)
                                Text("Continue with Apple")
                                    .font(.subheadline)
                                    .padding(.leading, 5)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.black)
                            .foregroundColor(.white)
                            
                     
                        }.clipShape(UnevenRoundedRectangle(topLeadingRadius: 10, bottomLeadingRadius: 10, bottomTrailingRadius: 10))
                        
                        Button(action: {
                        }) {
                            HStack {
                                Image(systemName: "g.circle.fill")
                                    .font(.title)
                                Text("Continue with Google")
                                    .font(.subheadline)
                                    .padding(.leading, 5)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.red)
                            .foregroundColor(.white)
                   
                        }.clipShape(UnevenRoundedRectangle(topLeadingRadius: 10, bottomLeadingRadius: 10, bottomTrailingRadius: 10))
                    }
                    
                    .padding(.horizontal)
                    
                    
                    Spacer()
                    
                    Button(action: {
                        authViewModel.signUp(email: email, password: password)
                    }) {
                        Text("Don't have any account? Sign Up Free")
                    }.padding(.bottom, 20)
                    
                    if authViewModel.isAuthenticated {
                        Text("Giriş başarılı!")
                            .foregroundColor(.green)
                            .font(.headline)
                    }
                }
                .padding()
            }.ignoresSafeArea(.all)
        }.background(Color.foreground)
    }
}

#Preview {
    LoginView(authViewModel: AuthenticationViewModel(isAuthenticated: true))
}
