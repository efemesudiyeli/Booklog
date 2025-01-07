//
//  EndSessionSheet.swift
//  Booklog
//
//  Created by Efe Mesudiyeli on 11.12.2024.

import SwiftUI


struct SessionEndView: View {
    @ObservedObject var bookViewModel: BookViewModel
    @State private var userNotes: String = ""
    @State var bookmarkPage: Int
    @FocusState private var isNotesFocused: Bool 
    let bookID: String
    var bookPageCount: Int
    var onSave: ((String, Int) -> Void)?
    @Environment(\.dismiss) private var dismiss

    
    var body: some View {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Notes")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding([.top, .horizontal])

                    Text("Organize your notes and bookmarks here.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding([.horizontal])

                    VStack(spacing: 15) {
                        Text("Notes")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        TextEditor(text: $userNotes)
                            .focused($isNotesFocused)
                            .frame(height: 200)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                            .onTapGesture {
                                isNotesFocused = true
                            }
                    }
                    .padding([.horizontal])

                    VStack(spacing: 15) {
                        Text("Last Page Read")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Picker("Page", selection: $bookmarkPage) {
                            ForEach(0...bookPageCount, id: \.self) { Int in
                                Text(Int.description)
                            }
                        }
                        .pickerStyle(.wheel)
                        .padding(.bottom)
                    }
                    .padding([.horizontal])

                    Spacer()

                    Button(action: {
                        isNotesFocused = false
                        onSave?(userNotes, bookmarkPage)
                        bookViewModel.saveSessionData(bookID: bookID, notes: userNotes, bookmarkPage: bookmarkPage)
                       
                        dismiss()
                    }) {
                        Text("Save and log")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding([.horizontal, .bottom])
                }
                .background(Color(.systemGroupedBackground))
                .cornerRadius(12)
                .padding()
            
            .onAppear {
                bookViewModel.fetchSessionData(bookID: bookID) { notes, page in
                    self.userNotes = notes
                    self.bookmarkPage = min(page, bookPageCount)
                }
            }
            .onTapGesture {
                isNotesFocused = false
            }
        }
    }
#Preview {
    let mockViewModel = BookViewModel()
    SessionEndView(bookViewModel: mockViewModel, bookmarkPage: 0, bookID: "testBookID", bookPageCount: 300) { notes, page in
        print("Saved Notes: \(notes), Bookmark Page: \(page)")
    }
}
