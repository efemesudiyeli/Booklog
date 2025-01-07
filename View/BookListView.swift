import SwiftUI

struct BookListView: View {
    @ObservedObject var viewModel: BookViewModel
    
    func cleanHTML(_ html: String) -> String {
        return html
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n\n", with: "\n")
        
    }
    
    func formatReadingTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours > 0 {
            return "\(hours) hours \(minutes) minutes"
        } else {
            return "\(minutes) minutes"
        }
    }
    
    func extractFirstSentences(_ text: String, count: Int = 3) -> String {
        let sentences = text.split(separator: ".", maxSplits: count - 1, omittingEmptySubsequences: true)
        return sentences.map { String($0) }.joined(separator: ". ") + (sentences.count > count ? "..." : "")
    }
    
    func formatDate(_ dateString: String) -> String {
        let fullDateFormatter = ISO8601DateFormatter()
        fullDateFormatter.formatOptions = [.withFullDate]
        
        let yearMonthFormatter = DateFormatter()
        yearMonthFormatter.dateFormat = "yyyy-MM"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .long
        outputFormatter.timeStyle = .none
        outputFormatter.locale = Locale.current
        
        if let date = fullDateFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        
        if let date = yearMonthFormatter.date(from: dateString) {
            outputFormatter.dateFormat = "MMMM yyyy"
            return outputFormatter.string(from: date)
        }
        
        return dateString
    }
    
    func formatBookDetails(_ book: BookItem) -> String {
        
        
        var details = """
        Book Title: \(book.volumeInfo.title) \(book.volumeInfo.subtitle ?? "")
        """
        
        if let authors = book.volumeInfo.authors?.joined(separator: ", ") {
            details += "\nAuthors: \(authors)"
        }
        if let publisher = book.volumeInfo.publisher {
            details += "\nPublisher: \(publisher)"
        }
        if let publishedDate = book.volumeInfo.publishedDate {
            details += "\nPublished Date: \(formatDate(publishedDate))"
        }
        if let categories = book.volumeInfo.categories?.joined(separator: ", ") {
            details += "\nCategories: \(categories)"
        }
        if let language = book.volumeInfo.language {
            details += "\nLanguage: \(language.uppercased())"
        }
        if let description = book.volumeInfo.description {
            let cleanedDescription = cleanHTML(description)
            let shortenedDescription = extractFirstSentences(cleanedDescription, count: 3)
            details += "\nDescription: \(shortenedDescription)"
        }
        if let bookmarkPage = book.bookmarkPage,
           let pageCount = book.volumeInfo.pageCount,
           pageCount > 0 {
            details += "\nReading Progress: \(bookmarkPage) / \(pageCount)"
        }
        if let identifiers = book.volumeInfo.industryIdentifiers {
            for identifier in identifiers {
                details += "\n\(identifier.type): \(identifier.identifier)"
            }
        }
        details += "\nBook Link: \(book.volumeInfo.canonicalVolumeLink)"
        details += "\nPlease download our app: https://booklog.app"
        return details
    }
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    if viewModel.books.isEmpty {
                        Text("There are no books saved yet.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(viewModel.books.sorted(by: { $0.volumeInfo.title < $1.volumeInfo.title }), id: \.id) { book in
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
                                        
                                        if let subtitle = book.volumeInfo.subtitle {
                                            Text(subtitle)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        
                                        if let authors = book.volumeInfo.authors?.joined(separator: ", ") {
                                            Text(authors)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                    ShareLink(item: formatBookDetails(book)) {
                                        Image(systemName: "square.and.arrow.up")
                                            .foregroundColor(.blue)
                                    }
                                    Button(action: {
                                        viewModel.removeBookFromUser(book: book)
                                    }) {
                                        Image(systemName: "bookmark.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                VStack(alignment: .leading) {
                                    if let publisher = book.volumeInfo.publisher {
                                        Text("Publisher: \(publisher)")
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    if let publishedDate = book.volumeInfo.publishedDate {
                                        
                                        Text("Published Date: \(formatDate(publishedDate))")
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                        
                                    }
                                    
                                    if let categories = book.volumeInfo.categories?.joined(separator: ", ") {
                                        Text("Categories: \(categories)")
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    if let language = book.volumeInfo.language {
                                        Text("Language: \(language.uppercased())")
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    if let readingTime = book.readingTime {
                                        Text("Read Time: \(formatReadingTime(readingTime))")
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    if let description = book.volumeInfo.description {
                                        ScrollView {
                                            Text(cleanHTML(description))
                                                .font(.footnote)
                                        }
                                        .frame(maxHeight: 150)
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.bottom, 10)
                                
                                
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
                                
                                HStack {
                                    Spacer()
                                    if let identifiers = book.volumeInfo.industryIdentifiers {
                                        HStack {
                                            ForEach(identifiers, id: \.identifier) { identifier in
                                                Text("\(identifier.type): \(identifier.identifier)")
                                                    .font(.system(size: 6))
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .padding(.trailing, 10)
                                    }
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
            .navigationTitle("Saved Books")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    ShareLink(item: viewModel.books.map { formatBookDetails($0) }.joined(separator: "\n\n"))
                }
            }
            .navigationBarTitleDisplayMode(.large)
            
            .onAppear {
                viewModel.fetchSavedBooks()
            }
        }
    }
}

#Preview {
    BookListView(viewModel: BookViewModel())
}


