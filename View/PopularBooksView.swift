//
//  PopularBooksView.swift
//  Booklog
//
//  Created by Efe Mesudiyeli on 4.01.2025.
//


import SwiftUI

struct PopularBooksView: View {
    @ObservedObject var viewModel: BookViewModel
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {            
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(viewModel.recommendedBooks, id: \.id) { book in
                                  VStack(spacing: 10) { 
                                      AsyncImage(url: URL(string: book.volumeInfo.imageLinks?.thumbnail ?? "")) { phase in
                                          switch phase {
                                          case .empty:
                                              Color.gray
                                                  .frame(width: 100, height: 150)
                                                  .cornerRadius(10)
                                          case .success(let image):
                                              image
                                                  .resizable()
                                                  .scaledToFit()
                                                  .frame(width: 100, height: 150)
                                                  .cornerRadius(10)
                                          case .failure:
                                              Image(systemName: "book")
                                                  .resizable()
                                                  .scaledToFit()
                                                  .frame(width: 100, height: 150)
                                                  .cornerRadius(10)
                                          @unknown default:
                                              EmptyView()
                                          }
                                      }

                                      Text(book.volumeInfo.title)
                                          .font(.footnote)
                                          .multilineTextAlignment(.center)
                                          .lineLimit(2)
                                          .frame(width: 100)
                                  }
                                  .frame(width: 120) 
                                  .padding()
                                  .cornerRadius(10)
                }
            }
            .padding()
        }
       
    }
}
