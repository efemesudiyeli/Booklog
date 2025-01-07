import SwiftUI

struct SearchBookView: View {
    @ObservedObject var bookViewModel: BookViewModel
    @State private var textInput: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Search a book...", text: $textInput)
                        .textFieldStyle(.roundedBorder)
                    
                    
                    Button(action: {
                        bookViewModel.searchBooks(query: textInput)
                    }) {
                        Image(systemName: "magnifyingglass")
                            .padding(8)
                            .background(textInput.isEmpty ? .gray : .blue)
                            .animation(.bouncy, value: textInput.isEmpty)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }.disabled(textInput.isEmpty)
                    
                }
                
                .padding([.leading, .trailing])
                
                Spacer()
                
                
                
                if bookViewModel.isLoading {
                    ProgressView("Loading...")
                        .padding()
                } else if !bookViewModel.searchResults.isEmpty {
                    ScrollView {
                        LazyVStack {
                            ForEach(
                                bookViewModel.searchResults,
                                id: \ .id
                            ) { book in
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        AsyncImage(url: URL(string: book.volumeInfo.imageLinks?.thumbnail ?? "")) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
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
                                            if let authors = book.volumeInfo.authors?.joined(separator: ", ") {
                                                Text(authors)
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        Spacer()
                                        Button(
                                            action: {
                                                if bookViewModel
                                                    .isBookAdded(book: book) {
                                                    bookViewModel
                                                        .removeBookFromUser(
                                                            book: book
                                                        )
                                                } else {
                                                    bookViewModel
                                                        .addBookToUser(book: book)
                                                }
                                            }) {
                                                Image(
                                                    systemName: bookViewModel
                                                        .isBookAdded(
                                                            book: book
                                                        ) ? "bookmark.fill" : "bookmark"
                                                )
                                                .foregroundColor(.blue)
                                            }
                                    }
                                    .padding()
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding()
                    }
                } else if !textInput.isEmpty {
                    Text("Now you can use search button")
                        .foregroundColor(.gray)
                        .padding()
                    
                } else if bookViewModel.searchResults.isEmpty && !bookViewModel.isLoading {

                   
                    PopularBooksView(viewModel: bookViewModel)
                
                }
                
                
            }
            .navigationTitle("Search Books")
            .navigationBarTitleDisplayMode(.large)
          
            Spacer()
        }
    }
}


#Preview {
    SearchBookView(bookViewModel: BookViewModel())
}
