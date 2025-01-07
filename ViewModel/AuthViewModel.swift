import FirebaseAuth
import FirebaseFirestore

class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    var isUpdating: Bool = false
    
    
    init(isAuthenticated: Bool = false) {
        self.isAuthenticated = isAuthenticated
        self.currentUser = Auth.auth().currentUser
        self.authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                self?.isAuthenticated = true
                self?.currentUser = user
            } else {
                self?.isAuthenticated = false
                self?.currentUser = nil
            }
        }
    }
    
    deinit {
        if let handle = authStateDidChangeListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(error)
                return
            }
            self.isAuthenticated = true
            self.currentUser = result?.user
            completion(nil)
        }
    }

    
    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Kayıt hatası: \(error.localizedDescription)")
                return
            }
            self.isAuthenticated = true
            self.currentUser = result?.user
            
            if let user = result?.user {
                let db = Firestore.firestore()
                let userData: [String: Any] = [
                    "userId": user.uid,
                    "savedBooks": [],
                    "nickname": email.components(separatedBy: "@").first ?? "User",
                    "email": email,


                ]
                
                db.collection("users").document(user.uid).setData(userData) { error in
                    if let error = error {
                        print("Firestore kullanıcı ekleme hatası: \(error.localizedDescription)")
                    } else {
                        print("Kullanıcı Firestore'a başarıyla eklendi.")
                    }
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isAuthenticated = false
            self.currentUser = nil
        } catch {
            print("Çıkış hatası: \(error.localizedDescription)")
        }
    }
    


    func updateNickname(newNickname: String, completion: @escaping (Error?) -> Void) {
        print("updateNickname çağrıldı")

        guard !isUpdating else { return }
        isUpdating = true
        
        guard let userId = currentUser?.uid else {
            print("Kullanıcı oturum açmamış.")
            isUpdating = false
            completion(NSError(domain: "UserNotLoggedIn", code: -1, userInfo: nil))
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(userId).updateData([
            "nickname": newNickname
        ]) { error in
            self.isUpdating = false
            if let error = error {
                print("Nickname güncellenirken hata oluştu: \(error.localizedDescription)")
                completion(error)
            } else {
                print("Nickname başarıyla güncellendi.")
                completion(nil)
            }
        }
    }
    
    func fetchNickname(completion: @escaping (String?) -> Void) {
        guard let userId = currentUser?.uid else {
            print("Kullanıcı oturum açmamış.")
            completion(nil)
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Nickname çekilirken hata oluştu: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = document?.data(),
                  let email = data["email"] as? String else {
                print("Kullanıcı bilgisi bulunamadı.")
                completion(nil)
                return
            }
            
            let nickname = data["nickname"] as? String ?? email.components(separatedBy: "@").first
            completion(nickname)
        }
    }
    func getErrorMessage(_ error: Error) -> String {
            let nsError = error as NSError
            print("Error code: \(nsError.code)") // Hata kodunu konsola yazdır
            if let errorCode = AuthErrorCode(rawValue: nsError.code) {
                switch errorCode {
                case .wrongPassword:
                    return "The password you entered is incorrect. Please try again."
                case .userNotFound:
                    return "No account found with this email. Please check your email address or sign up."
                case .invalidEmail:
                    return "The email address format is invalid. Please check and try again."
                case .emailAlreadyInUse:
                    return "This email is already in use. Please try logging in or use another email."
                case .weakPassword:
                    return "Your password is too weak. Please use a stronger password."
                case .tooManyRequests:
                    return "Too many attempts. Please try again later."
                default:
                    return "An unknown error occurred. Please try again."
                }
            } else {
                return "An unknown error occurred. Please try again."
            }
        }



}
