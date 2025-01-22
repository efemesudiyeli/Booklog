//
//  MyStatsView.swift
//  Booklog
//
//  Created by Efe Mesudiyeli on 22.01.2025.
//

import SwiftUI

struct MyStatsView: View {
    @Binding  var userStatistics: [String: Any]

    
    var body: some View {
        VStack {
            if let totalPagesRead = userStatistics["totalPagesRead"] as? Int,
               let totalBooksCompleted = userStatistics["totalBooksCompleted"] as? Int,
               let totalSessions = userStatistics["totalSessions"] as? Int {
     
                Group {
                    Text("My Stats")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "book.pages")
                            Text("Total Pages Read:").bold()
                            Text("\(totalPagesRead)")
                        }
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Total Books Completed:").bold()
                            Text("\(totalBooksCompleted)")
                        }
                        HStack {
                            Image(systemName: "clock")
                            Text("Total Sessions:").bold()
                            Text("\(totalSessions)")
                        }
                    }
                    .padding(.top, 2)
                    .padding()
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.cSecondary)
                    .foregroundStyle(Color.white)
                    .cornerRadius(10)
                }
            } else {
                // Placeholder içerik
                VStack {
                    Text("My Stats")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ZStack(alignment: .center) {
                       
                            Text("No data available yet.")
                                .font(.callout)
                                .bold()
                        
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "book.pages")
                                Text("Total Pages Read:").bold()
                                Text("635")
                            }
                            HStack {
                                Image(systemName: "checkmark")
                                Text("Total Books Completed:").bold()
                                Text("4")
                            }
                            HStack {
                                Image(systemName: "clock")
                                Text("Total Sessions:").bold()
                                Text("34")
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .blur(radius: 5)
                    }
                    .padding()
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .background(Color.cSecondary)
                    .foregroundStyle(Color.white)
                    .cornerRadius(10)
                }
                
               

            }
        }

    }
}
