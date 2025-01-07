//
//  BookSelectionView.swift
//  Booklog
//
//  Created by Efe Mesudiyeli on 11.12.2024.
//

import SwiftUI

struct BookSelectionView: View {
    @Binding var selectedBook: BookItem?
    let books: [BookItem]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    ForEach(books.sorted(by: { $0.volumeInfo.title < $1.volumeInfo.title }), id: \.id) { book in
                        Button(action: {
                            selectedBook = book
                        }) {
                            VStack(alignment: .leading) {
                                HStack {
                                    AsyncImage(url: URL(string: book.volumeInfo.imageLinks?.thumbnail ?? "")) { phase in
                                        switch phase {
                                        case .empty:
                                            Image(systemName: "book")
                                                .frame(width: 50, height: 50)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 50, height: 50)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                        case .failure:
                                            Image(systemName: "book")
                                                .frame(width: 50, height: 50)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    VStack(alignment: .leading) {
                                        Text(book.volumeInfo.title)
                                            .font(.headline)
                                            .multilineTextAlignment(.leading)
                                        if let authors = book.volumeInfo.authors?.joined(separator: ", ") {
                                            Text(authors)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    
                                }
                                .padding()
                                
                                if let bookmarkPage = book.bookmarkPage,
                                   let pageCount = book.volumeInfo.pageCount,
                                   pageCount > 0 {
                                    VStack (alignment: .leading) {
                                        Text("Progress: \(bookmarkPage) / \(pageCount)")
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                        
                                        ProgressView(value: Double(bookmarkPage) / Double(pageCount))
                                        
                                            .progressViewStyle(
                                                CustomProgressViewStyle(color: .blue)
                                            )
                                    }
                                    .padding(.horizontal, 10)
                                    
                                }
                                
                                Divider()
                            }
                            
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.bottom)
            }
            .navigationTitle("Select a book")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    BookSelectionView(
        selectedBook: .constant(nil),
        books: []
    )
}

