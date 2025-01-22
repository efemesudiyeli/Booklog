//
//  ReadingGoalView.swift
//  Booklog
//
//  Created by Efe Mesudiyeli on 22.01.2025.
//

import SwiftUI

struct ReadingGoalView: View {
    @State private var dailyTotalReadTime: Int = 0 // Kullanıcının okuduğu toplam dakika
    @State private var readingGoal: Int = 0
    @State private var showConfetti: Bool = false // Konfeti kontrolü
    @ObservedObject var bookViewModel: BookViewModel
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Daily Reading Goal")
                .font(.headline)
            
            VStack(alignment: .center) {
                let progressValue = max(0, min(Double(dailyTotalReadTime), Double(readingGoal)))
                let progressTotal = max(1, Double(readingGoal))
                
                ProgressView(
                    value: progressValue,
                    total: progressTotal
                )
                .progressViewStyle(CustomProgressViewStyle(
                    color: dailyTotalReadTime >= readingGoal ? .green : .white,
                    progressStartString: "\(dailyTotalReadTime)",
                    progressEndString: "\(readingGoal)"))
                
                .padding(.horizontal)
                
                
                
                Group() {
                    let halfwayReached = (readingGoal / 2) <= dailyTotalReadTime
                    let notCompleted = dailyTotalReadTime < readingGoal
                    let completed = dailyTotalReadTime >= readingGoal
                    
                    
                    if halfwayReached && notCompleted {
                        Text("You’re almost there, just a little more to go! Only \(readingGoal - dailyTotalReadTime) minutes stand between you and your goal!")
                            .font(.footnote)
                            .foregroundColor(.yellow)
                            .bold()
                    } else if completed {
                        Text("Well done, you did it! Congratulations on reaching your goal!")
                            .font(.footnote)
                            .foregroundColor(.green)
                            .bold()
                    }
                }
                .multilineTextAlignment(.center)
            }
            .displayConfetti(isActive: $showConfetti)
            .padding()
            .background(.cSecondary)
            .cornerRadius(10)
            
        }
        .onAppear {
            bookViewModel.updateDailyReadingTime(seconds: 0)
            bookViewModel.fetchReadingGoal { goal in
                if let goal = goal {
                    readingGoal = goal
                }
            }
            
     
            bookViewModel.fetchDailyReadingProgress { dailyMinutes, goal in
                self.dailyTotalReadTime = dailyMinutes
                self.readingGoal = goal
                
                if dailyTotalReadTime >= readingGoal {
                    showConfetti = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        withAnimation(.easeOut(duration: 3.0)) {
                            showConfetti = false
                        }
                    }
                } else {
                    showConfetti = false
                }
            }
        }
        
    }
}
