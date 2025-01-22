//
//  SessionView.swift
//  Booklog
//
//  Created by Efe Mesudiyeli on 8.12.2024.
//

import SwiftUI
import FirebaseAuth
import Firebase

struct SessionView: View {
    @State private var showEndSessionForm: Bool = false
    @State private var isBookSelectionPresented = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var isPaused: Bool = true
    @ObservedObject var bookViewModel: BookViewModel
    @State var selectedBook: BookItem?
    @State private var userNotes: String = ""
    @State private var bookmarkPage: String = ""
    
    
    func handleSessionEnd(notes: String, bookmarkPage: Int) {
        guard let book = selectedBook else { return }
        let elapsedSeconds = Int(elapsedTime)
        
        // Günlük süreyi Firestore'da güncelle
        bookViewModel.updateDailyReadingTime(seconds: elapsedSeconds)
        
        let totalPages = book.volumeInfo.pageCount ?? 0
        let previousPage = selectedBook?.bookmarkPage ?? 0
        let pagesRead = max(0, bookmarkPage - previousPage)
        
        print("Previous Page: \(previousPage), Current Page: \(bookmarkPage), Pages Read: \(pagesRead)")
        
        // Her durumda totalSessions ve totalPagesRead güncellenir
        bookViewModel.updateUserStatistics(
            bookID: book.id,
            elapsedSeconds: elapsedSeconds,
            pagesRead: pagesRead,
            isBookCompleted: bookmarkPage >= totalPages
        )
        
        if bookmarkPage >= totalPages {
            // Kitap tamamlandı
            print("Book completed! Updating completion status.")
            
            // Kitap tamamlanma verilerini kaydet
            bookViewModel.checkAndUpdateCompletionStatus(
                bookID: book.id,
                notes: notes,
                bookmarkPage: bookmarkPage,
                elapsedSeconds: elapsedSeconds
            )
            
            // Tamamlandı olarak işaretleyin
            selectedBook?.bookmarkPage = totalPages
            selectedBook?.notes = notes
        } else {
            // Kitap tamamlanmadı, oturum verilerini kaydedin
            print("Book not completed, updating session data only.")
            bookViewModel.updateBookWithSessionData(
                bookID: book.id,
                notes: notes,
                bookmarkPage: bookmarkPage
            )
        }
        
        // Süreyi sıfırla
        elapsedTime = 0
        selectedBook?.bookmarkPage = bookmarkPage
    }
    
    private func startTimer() {
        if timer == nil { // Zaten çalışıyorsa yeniden başlatma
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                elapsedTime += 1
            }
            isPaused = false
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isPaused = true
    }
    
    private func toggleTimer() {
        if isPaused {
            startTimer()
        } else {
            stopTimer()
        }
    }
    
    var body: some View {
        VStack {
            if selectedBook != nil {
                VStack(alignment: .leading) {
                    HStack(spacing: 20) {
                        Button {
                            stopTimer()
                            selectedBook = nil
                            isBookSelectionPresented = true
                        } label: {
                            Image(systemName: "arrow.uturn.left")
                                .foregroundStyle(.blue)
                                .font(.system(size: 20))
                        }
                        
                        Spacer()
                        
                        
                        
                        Button {
                            stopTimer()
                            elapsedTime = 0
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundStyle(.blue)
                                .font(.system(size: 20))
                        }
                        
                        Button {
                            stopTimer()
                            showEndSessionForm = true
                        } label: {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.green)
                                .font(.system(size: 20))
                        }
                        
                        
                    }
                    
                    HStack {
                        Spacer()
                        if let image = selectedBook?.volumeInfo.imageLinks?.thumbnail {
                            AsyncImage(url: URL(string: image)) { phase in
                                switch phase {
                                case .empty:
                                    Color.gray
                                        .frame(width: 100, height: 150)
                                        .cornerRadius(8)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 150)
                                        .cornerRadius(8)
                                        .shadow(radius: 3)
                                case .failure:
                                    Color.gray
                                        .frame(width: 100, height: 150)
                                        .cornerRadius(8)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            Color.gray
                                .frame(width: 100, height: 150)
                                .cornerRadius(8)
                        }
                        Spacer()
                    }
                    .padding(.top)
                    
                    
                    if let title = selectedBook?.volumeInfo.title {
                        Text(title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                    
                    if let authors = selectedBook?.volumeInfo.authors?.joined(separator: ", ") {
                        Text("Author: \(authors)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    if let pageCount = selectedBook?.volumeInfo.pageCount {
                        Text("Page Count: \(pageCount)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    
                }
                
                .padding()
                .shadow(radius: 1)
                
                Spacer()
                
                VStack {
                    Text("Elapsed Time")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("\(Int(elapsedTime)) seconds")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Button {
                    toggleTimer()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.cBackground)
                            .frame(width: 200)
                        Image(systemName: isPaused ? "play.fill" : "pause.fill")
                            .foregroundStyle(Color.primary)
                            .font(.system(size: 46))
                            .rotationEffect(.degrees(isPaused ? 0 : 180))
                            .animation(.easeInOut(duration: 0.3), value: isPaused)
                    }
                }.buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                
            } else {
                BookSelectionView(selectedBook: $selectedBook, books: bookViewModel.books)
            }
        }
        
        
        
        .padding()
        .sheet(isPresented: $showEndSessionForm) {
            if let selectedBook = selectedBook {
                SessionEndView(
                    bookViewModel: bookViewModel,
                    bookmarkPage: selectedBook.bookmarkPage ?? 0,
                    bookID: selectedBook.id,
                    bookPageCount: selectedBook.volumeInfo.pageCount ?? 500
                ) { notes, page in
                    handleSessionEnd(notes: notes, bookmarkPage: page)
                }
            }
        }
        
        .onDisappear {
            stopTimer()
        }
        .onChange(of: bookViewModel.books) { updatedBooks in
            // Seçili kitabın artık mevcut olmadığını kontrol et
            if let currentBook = selectedBook, !updatedBooks.contains(where: { $0.id == currentBook.id }) {
                selectedBook = nil // Seçili kitabı sıfırla
            }
        }
        .onAppear {
            bookViewModel.fetchSavedBooks()
            
            // İlk yüklemede seçili kitabın geçerli olup olmadığını kontrol et
            if let currentBook = selectedBook, !bookViewModel.books.contains(where: { $0.id == currentBook.id }) {
                selectedBook = nil
            }
        }
    }
}
