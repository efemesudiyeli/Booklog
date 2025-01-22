import SwiftUI

struct SignupView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var passwordAgain = ""
    @State private var showPasswordMismatchError: Bool = false
    @State private var showEmailFormatError: Bool = false
    @ObservedObject var authViewModel: AuthenticationViewModel
    
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
                                prompt: Text("E-mail")
                                    .foregroundStyle(.white.opacity(0.5))
                            )
                            .textFieldStyle(
                                CustomTextFieldStyle(
                                    iconName: "envelope.fill"
                                )
                            )
                            .keyboardType(.emailAddress)
                            .frame(maxWidth: 320)
                            .autocapitalization(.none)
                        } else {
                            TextField(
                                "",
                                text: $email,
                                prompt: Text("Placeholder")
                                    .foregroundColor(.white.opacity(0.5))
                            )
                            .textFieldStyle(
                                CustomTextFieldStyle(
                                    iconName: "envelope.fill"
                                )
                            )
                            .keyboardType(.emailAddress)
                            .frame(maxWidth: 320)
                            .autocapitalization(.none)
                        }
                            
                        
                        if showEmailFormatError {
                            Text("Invalid email format!")
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .padding(10)
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
                            .frame(maxWidth: 320)
                      
                        
                            SecureField(
                                "",
                                text: $passwordAgain,
                                prompt: Text("Password Again")
                                    .foregroundStyle(.white.opacity(0.5))
                            )
                            .textFieldStyle(CustomTextFieldStyle(iconName: "lock.fill"))
                            .frame(maxWidth: 320)
                        }
                        else {
                            SecureField(
                                "",
                                text: $password,
                                prompt: Text("Password")
                                    .foregroundColor(.white.opacity(0.5))
                            )
                            .textFieldStyle(
                                CustomTextFieldStyle(iconName: "lock.fill")
                            )
                            .frame(maxWidth: 320)
                      
                        
                            SecureField(
                                "",
                                text: $passwordAgain,
                                prompt: Text("Password Again")
                                    .foregroundColor(.white.opacity(0.5))
                            )
                            .textFieldStyle(CustomTextFieldStyle(iconName: "lock.fill"))
                            .frame(maxWidth: 320)
                        }
                        
                        if showPasswordMismatchError {
                            Text("Passwords do not match!")
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .padding(.top, 20)
                        }
                        VStack(spacing: 20) { // Dikey düzenleme
                            Button(action: {
                                if !authViewModel.isValidEmail(email) {
                                    showEmailFormatError = true
                                    showPasswordMismatchError = false
                                } else if password != passwordAgain {
                                    showPasswordMismatchError = true
                                    showEmailFormatError = false
                                } else {
                                    showEmailFormatError = false
                                    showPasswordMismatchError = false
                                    authViewModel.signUp(email: email, password: password)
                                }
                            }) {
                                Text("Sign Up")
                                    .frame(maxWidth: .infinity, maxHeight:  50)
                                    .background(Color.cAccent)
                                    .foregroundColor(.cPrimary)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .padding(.vertical)
                            
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
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                        
                        
                        
                    }
                    .padding()
                }
                
                
                NavigationLink {
                    LoginView(authViewModel: authViewModel)
                } label: {
                    Text("Log in instead")
                        .font(.title3)
                        .foregroundStyle(.cAccent)
                }
                
            }.background(Color.cBackground)
                .navigationBarBackButtonHidden()
                .scrollDismissesKeyboard(
                    .immediately
                ) // Klavyeyi kaydırarak kapatma
                .ignoresSafeArea(
                    .keyboard,
                    edges: .vertical
                ) // Klavyeyi görmezden gelir

                
        
    }
    
}




#Preview {
    SignupView(authViewModel: AuthenticationViewModel(isAuthenticated: true))
}
