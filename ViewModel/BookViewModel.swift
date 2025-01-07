import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreInternal
import SwiftUI

class BookViewModel: ObservableObject {
    @Published var books: [BookItem] = []
    @Published var searchResults: [BookItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var updatingBooks: Set<String> = []
    @Published var userNotes: String = ""
    @Published var bookmarkPage: String = ""
    @Published var recommendedBooks: [BookItem] = []
    private var db = Firestore.firestore()
    
    func getGoogleAPIKey() -> String? {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let dictionary = NSDictionary(contentsOfFile: path),
              let apiKey = dictionary["API_KEY"] as? String else {
            print("API key not found in GoogleService-Info.plist")
            return nil
        }
        return apiKey
    }
    
    func searchBooks(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        searchResults = []
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(encodedQuery)&maxResults=20"
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Geçersiz URL"
            }
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Ağ hatası: \(error.localizedDescription)"
                    self?.isLoading = false
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "Veri alınamadı"
                    self?.isLoading = false
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(BooksResponse.self, from: data)
                    self?.searchResults = response.items
                    self?.isLoading = false
                } catch {
                    self?.errorMessage = "Veri işleme hatası"
                    self?.isLoading = false
                }
            }
        }
        
        task.resume()
    }
    
    func fetchSavedBooks() {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "Oturum açmış kullanıcı bulunamadı"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                }
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data(),
                  let savedBooksIds = data["savedBooks"] as? [String] else {
                DispatchQueue.main.async {
                    self?.books = []
                    self?.isLoading = false
                }
                return
            }
            
            if savedBooksIds.isEmpty {
                DispatchQueue.main.async {
                    self?.books = []
                    self?.isLoading = false
                }
                return
            }
            
            self?.fetchBooksDetails(for: savedBooksIds)
        }
    }
    
    private func fetchBooksDetails(for ids: [String]) {
        let group = DispatchGroup()
        var fetchedBooks: [BookItem] = []
        
        for id in ids {
            group.enter()
            
            guard let url = URL(string: "https://www.googleapis.com/books/v1/volumes/\(id)") else {
                group.leave()
                continue
            }
            
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                defer { group.leave() }
                
                if let error = error {
                    print("Error fetching book details: \(error)")
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    var book = try JSONDecoder().decode(BookItem.self, from: data)
                    
                    self?.fetchCustomBookData(bookID: id) { notes, bookmarkPage, readingTime in
                        DispatchQueue.main.async {
                            book.notes = notes
                            book.bookmarkPage = bookmarkPage
                            book.readingTime = readingTime
                            
                            fetchedBooks.append(book)
                            
                            if fetchedBooks.count == ids.count {
                                self?.books = fetchedBooks.sorted {
                                    guard let timestamp1 = $0.timestamp, let timestamp2 = $1.timestamp else { return false }
                                    return timestamp1 > timestamp2
                                }
                                self?.isLoading = false
                            }
                        }
                    }
                } catch {
                    print("Error decoding book: \(error)")
                }
            }.resume()
        }
    }
    
    private func fetchCustomBookData(bookID: String, completion: @escaping (String?, Int?, Int?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User ID not found.")
            completion(nil, nil, nil)
            return
        }
        
        db.collection("users").document(userId).collection("books").document(bookID).getDocument { document, error in
            if let error = error {
                print("Error fetching custom book data for book \(bookID): \(error)")
                completion(nil, nil, nil)
                return
            }
            
            guard let data = document?.data() else {
                print("No data found for book \(bookID).")
                completion(nil, nil, nil)
                return
            }
            
            let notes = data["notes"] as? String
            let bookmarkPage = data["bookmarkPage"] as? Int
            let readingTime = data["readingTime"] as? Int
            
            print("Fetched custom data for book \(bookID): notes=\(notes ?? "nil"), bookmarkPage=\(bookmarkPage ?? -1), readingTime=\(readingTime ?? 0)")
            completion(notes, bookmarkPage, readingTime)
        }
    }
    
    // MARK: - Book Management
    
    func updateBookWithSessionData(
        bookID: String,
        notes: String,
        bookmarkPage: Int){
            guard let userId = Auth.auth().currentUser?.uid else { return }
            
            db.collection("users").document(userId).collection("books").document(bookID).updateData([
                "notes": notes,
                "bookmarkPage": bookmarkPage,
                "timestamp": FieldValue.serverTimestamp(),
            ]) { error in
                if let error = error {
                    print("Error updating book session data: \(error.localizedDescription)")
                } else {
                    print("Book session data updated successfully.")
                }
            }
        }
    
    func removeBookFromUser(book: BookItem) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).updateData([
            "savedBooks": FieldValue.arrayRemove([book.id])
        ]) { error in
            if let error = error {
                print("Error removing book: \(error)")
            } else {
                DispatchQueue.main.async {
                    self.books.removeAll { $0.id == book.id }
                }
            }
        }
    }
    
    func isBookAdded(book: BookItem) -> Bool {
        return books.contains(where: { $0.id == book.id })
    }
    
    func addBookToUser(book: BookItem) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).updateData([
            "savedBooks": FieldValue.arrayUnion([book.id])
        ]) { error in
            if let error = error {
                print("Error adding book: \(error)")
            } else {
                DispatchQueue.main.async {
                    self.books.append(book)
                }
            }
        }
    }
    
    // MARK: - Reading Goal
    
    func fetchReadingGoal(completion: @escaping (Int?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Error fetching reading goal: \(error)")
                completion(nil)
                return
            }
            let readingGoal = document?.data()?["readingGoal"] as? Int
            completion(readingGoal)
            print("Reading goal fetch: \(String(describing: readingGoal))")
        }
    }
    
    func updateReadingGoal(newGoal: Int) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userId).updateData([
            "readingGoal": newGoal
        ]) { error in
            if let error = error {
                print("Error updating reading goal: \(error)")
            } else {
                print("Reading goal updated to \(newGoal)!")
            }
        }
    }
    
    func fetchSessionData(bookID: String, completion: @escaping (String, Int) -> Void) {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).collection("books").document(bookID).getDocument { document, error in
            if let error = error {
                print("Error fetching session data: \(error)")
                completion("", 0)
                return
            }
            
            let notes = document?.data()?["notes"] as? String ?? ""
            let bookmarkPage = document?.data()?["bookmarkPage"] as? Int ?? 0
            completion(notes, bookmarkPage)
        }
    }
    
    func updateDailyReadingTimeInFirestore(minutes: Int, seconds: Int = 0) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        // Firestore verisini güncelle
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                return
            }
            
            guard let data = document?.data() else {
                print("No data found for user.")
                return
            }
            
            var dailyMinutesRead = data["dailyMinutesRead"] as? Int ?? 0
            var dailySeconds = data["dailySeconds"] as? Int ?? 0
            
            dailySeconds += seconds
            let additionalMinutes = dailySeconds / 60
            dailySeconds = dailySeconds % 60
            dailyMinutesRead += minutes + additionalMinutes
            
            db.collection("users").document(userId).updateData([
                "dailyMinutesRead": dailyMinutesRead,
                "dailySeconds": dailySeconds
            ]) { error in
                if let error = error {
                    print("Error updating daily reading time: \(error.localizedDescription)")
                } else {
                    print("Daily reading time updated: \(dailyMinutesRead)m \(dailySeconds)s")
                }
            }
        }
    }

    func updateDailyReadingTime(seconds: Int, completion: ((Bool) -> Void)? = nil) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion?(false)
            return
        }
        
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDateString = dateFormatter.string(from: currentDate)
        
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                completion?(false)
                return
            }
            
            guard let data = document?.data() else {
                completion?(false)
                return
            }
            
            var dailySeconds = data["dailySeconds"] as? Int ?? 0
            var dailyMinutesRead = data["dailyMinutesRead"] as? Int ?? 0
            let lastResetDate = data["lastResetDate"] as? String ?? ""
            var didReset = false
            
            if lastResetDate != currentDateString {
                print("Günlük sıfırlama yapılıyor: \(lastResetDate) -> \(currentDateString)")
                dailySeconds = 0
                dailyMinutesRead = 0
                didReset = true
            }
            
            dailySeconds += seconds
            let additionalMinutes = dailySeconds / 60
            dailySeconds = dailySeconds % 60
            dailyMinutesRead += additionalMinutes
            
            self.db.collection("users").document(userId).setData([
                "dailySeconds": dailySeconds,
                "dailyMinutesRead": dailyMinutesRead,
                "lastResetDate": currentDateString
            ], merge: true) { error in
                if let error = error {
                    print("Error updating daily reading time: \(error.localizedDescription)")
                    completion?(false)
                } else {
                    print("Daily reading time updated: \(dailyMinutesRead)m \(dailySeconds)s")
                    completion?(didReset)
                }
            }
        }
    }
    func saveSessionData(bookID: String, notes: String, bookmarkPage: Int) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User ID not found. Make sure the user is logged in.")
            return
        }
        
        print("Saving session data for bookID: \(bookID), notes: \(notes), bookmarkPage: \(bookmarkPage)")
        
        db.collection("users").document(userId).collection("books").document(bookID).setData([
            "notes": notes,
            "bookmarkPage": bookmarkPage,
            "timestamp": FieldValue.serverTimestamp()
        ], merge: true) { error in
            if let error = error {
                print("Error saving session data: \(error.localizedDescription)")
            } else {
                print("Session data saved successfully.")
            }
        }
    }
    
    func fetchUserStatistics(completion: @escaping ([String: Any]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Kullanıcı ID bulunamadı.")
            completion([:])
            return
        }
        
        db.collection("users").document(userId).getDocument {
            snapshot,
            error in
            if let error = error {
                print("Hata: \(error.localizedDescription)")
                completion([:])
                return
            }
            
            guard let data = snapshot?.data() else {
                print("Veri bulunamadı.")
                completion([:])
                return
            }
            
            let totalPagesRead = data["totalPagesRead"] as? Int ?? 0
            let totalBooksCompleted = data["totalBooksCompleted"] as? Int ?? 0
            let totalSessions = data["totalSessions"] as? Int ?? 0
            let totalMinutesRead = data["totalReadingTime"] as? Int ?? 0
            
            print(
                "totalPagesRead: \(totalPagesRead) totalBooksCompleted: \(totalBooksCompleted) totalSessions: \(totalSessions) totalMinutesRead: \(totalMinutesRead)"
            )
            
            completion([
                "totalPagesRead": totalPagesRead,
                "totalBooksCompleted": totalBooksCompleted,
                "totalSessions": totalSessions,
                "totalMinutesRead": totalMinutesRead
            ])
        }
    }
    
    func updateUserStatistics(bookID: String, elapsedSeconds: Int, pagesRead: Int, isBookCompleted: Bool) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).setData([
            "totalSessions": FieldValue.increment(1.0),
            "totalReadingTime": FieldValue.increment(Double(elapsedSeconds)),
            "totalPagesRead": FieldValue.increment(Double(pagesRead))
        ], merge: true)
        
        db.collection("users").document(userId).collection("books").document(bookID).setData([
            "sessionCount": FieldValue.increment(1.0),
            "readingTime": FieldValue.increment(Double(elapsedSeconds)),
            "timestamp": FieldValue.serverTimestamp()
        ], merge: true) { error in
            if let error = error {
                print("Error updating book statistics: \(error.localizedDescription)")
            } else {
                print("Book statistics updated successfully.")
            }
        }
    }
    
    func fetchDailyReadingProgress(completion: @escaping (Int, Int) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Kullanıcı ID bulunamadı.")
            completion(0, 0)
            return
        }
        
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Hata: \(error.localizedDescription)")
                completion(0, 0)
                return
            }
            
            guard let data = document?.data() else {
                print("Veri bulunamadı.")
                completion(0, 0)
                return
            }
            
            let dailyMinutesRead = data["dailyMinutesRead"] as? Int ?? 0
            let readingGoal = data["readingGoal"] as? Int ?? 0
            
            print("Günlük okunan süre: \(dailyMinutesRead), Hedef: \(readingGoal)")
            completion(dailyMinutesRead, readingGoal)
        }
    }
    
    func checkAndUpdateCompletionStatus(bookID: String, notes: String, bookmarkPage: Int, elapsedSeconds: Int) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let bookRef = db.collection("users").document(userId).collection("books").document(bookID)
        bookRef.getDocument { [weak self] document, error in
            if let error = error {
                print("Error fetching book data: \(error.localizedDescription)")
                return
            }
            
            let isCompleted = document?.data()?["isCompleted"] as? Bool ?? false
            
            if isCompleted {
                print("This book is already marked as completed.")
            } else {
                bookRef.setData([
                    "notes": notes,
                    "bookmarkPage": bookmarkPage,
                    "isCompleted": true,
                    "timestamp": FieldValue.serverTimestamp()
                ], merge: true)
                
                self?.updateUserStatistics(bookID: bookID, elapsedSeconds: elapsedSeconds, pagesRead: bookmarkPage, isBookCompleted: true)
            }
        }
    }
    
    func fetchWeeklyStatistics(completion: @escaping ([Int]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Kullanıcı oturumu açık değil.")
            completion([])
            return
        }
        
        db.collection("users").document(userId).getDocument { document, error in
            guard error == nil, let data = document?.data(),
                  let dailyTimes = data["dailyTimes"] as? [String: Int] else {
                print("Veri alınırken hata oluştu.")
                completion([])
                return
            }
            
            let calendar = Calendar.current
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let today = Date()
            
            var weeklyData: [Int] = []
            for dayOffset in -6...0 {
                if let date = calendar.date(byAdding: .day, value: dayOffset, to: today),
                   let minutes = dailyTimes[dateFormatter.string(from: date)] {
                    weeklyData.append(minutes)
                } else {
                    weeklyData.append(0)
                }
            }
            
            completion(weeklyData)
        }
    }
    
    func formatTime(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m \(secs)s"
        } else {
            return "\(minutes)m \(secs)s"
        }
    }
    
    func fetchDailyMotivation() -> String {
        let defaults = UserDefaults.standard
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let today = formatter.string(from: Date())
        let storedDate = defaults.string(forKey: "motivationDate")
        let storedMotivation = defaults.string(forKey: "dailyMotivation")
        
        if storedDate == today, let motivation = storedMotivation {
            return motivation
        } else {
           
            let newMotivation = MotivationQuotes.quotes.randomElement() ?? "Keep reading, keep growing!"
            defaults.set(today, forKey: "motivationDate")
            defaults.set(newMotivation, forKey: "dailyMotivation")
            return newMotivation
        }
    }
    
    func getLastSevenDays() -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        let calendar = Calendar.current
        let today = Date()
        
        return (0..<7).map {
            let day = calendar.date(byAdding: .day, value: -$0, to: today) ?? Date()
            return formatter.string(from: day)
        }.reversed()
    }
    
    
    
}



