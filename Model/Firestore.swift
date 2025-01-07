//
//  Firestore.swift
//  Booklog
//
//  Created by Efe Mesudiyeli on 23.11.2024.
//

import FirebaseFirestore

struct FirestoreUser: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var savedBooks: [String]
    var readingGoal: Int?

    
    init(userId: String, savedBooks: [String] = [], readingGoal: Int? = nil) {
        self.userId = userId
        self.savedBooks = savedBooks
        self.readingGoal = readingGoal

    }
}

struct FirestoreBook: Identifiable, Codable {
    var id: String
    var title: String
    var authors: [String]?
    var imageUrl: String?
    
    init(book: BookItem) {
        self.id = book.id
        self.title = book.volumeInfo.title
        self.authors = book.volumeInfo.authors
        self.imageUrl = book.volumeInfo.imageLinks?.thumbnail
    }
}
