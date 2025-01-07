import SwiftUI

//TODO: ŞİFRELER FARKLI GİRİLDİĞİNDE ERROR MESAJI GELMELİ

struct SignupView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var passwordAgain = ""
    @State private var showPasswordMismatchError: Bool = false
    @State private var showEmailFormatError: Bool = false    
    @ObservedObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        NavigationStack {
            
            
            VStack(spacing: 40) {
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
                        
                        if showEmailFormatError {
                            Text("Invalid email format!")
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .padding(10)
                        }

                        SecureField("Password", text: $password)
                            .textFieldStyle(CustomTextFieldStyle())
                            .frame(maxWidth: 350)
                        
                        SecureField("Password Again", text: $passwordAgain)
                            .textFieldStyle(CustomTextFieldStyle())
                            .frame(maxWidth: 350)
                        
                        if showPasswordMismatchError {
                            Text("Passwords do not match!")
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .padding(.top, 20)
                        }

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
                                .frame(maxWidth: 350)
                                .padding(.vertical)
                                .background(Color.foreground)
                                .foregroundColor(.background)
                                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 10, bottomLeadingRadius: 10, bottomTrailingRadius: 10))
                                .font(.headline)
                        }
                        .padding(.vertical)

                        
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

                        NavigationLink {
                            LoginView(authViewModel: authViewModel)
                        } label: {
                            Text("Log in")
                                .font(.title3)
                                .foregroundStyle(Color.foreground)
                        }.padding(.bottom, 20)

                    }
                    .padding()
                }.ignoresSafeArea(.all)
            }.background(Color.foreground)
        }
    }
}




#Preview {
    SignupView(authViewModel: AuthenticationViewModel(isAuthenticated: true))
}
