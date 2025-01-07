
import SwiftUI
import Charts

struct HomeView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    @ObservedObject var bookViewModel: BookViewModel
    @State private var readingGoal: Int = 0
    @State private var dailyTotalReadTime: Int = 0 // Kullanıcının okuduğu toplam dakika
    @State private var userStatistics: [String: Any] = [:]
    @State private var showConfetti: Bool = false // Konfeti kontrolü
    @State private var nickname: String = "Loading..."
    @State private var weeklyStatistics: [Int] = []
    @State private var days: [String] = []

    @State private var randomWelcomeMessage: String = "Welcome,"
    @State private var randomMotivation: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                //Header and Welcome
                VStack(alignment: .leading) {
                    
                    Text("Booklog")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding([.top])
                        .shadow(radius: 2)
                    
                    HStack {
                        Text(randomWelcomeMessage)
                        Text(nickname).bold() + Text("!")
                            .font(.title3)
                            .fontWeight(.light)
                            .foregroundColor(.primary)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Today's Motivation")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading) {
                        Text(randomMotivation)
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .italic()
                            .padding(.top, 5)
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                }
                
                // Daily Reading Goal
                VStack(alignment: .leading) {
                    Text("Daily Reading Goal")
                        .font(.headline)
                    
                    VStack(alignment: .leading) {
                        let progressValue = max(0, min(Double(dailyTotalReadTime), Double(readingGoal)))
                        let progressTotal = max(1, Double(readingGoal))
                        
                        ProgressView(
                            value: progressValue,
                            total: progressTotal
                        )
                        .progressViewStyle(CustomProgressViewStyle(
                            color: dailyTotalReadTime >= readingGoal ? .green : .blue,
                            progressStartString: "\(dailyTotalReadTime)",
                            progressEndString: "\(readingGoal)"))
                        
                        .padding(.horizontal)
                        
                        
                        
                        let halfwayReached = (readingGoal / 2) <= dailyTotalReadTime
                        let notCompleted = dailyTotalReadTime < readingGoal
                        let completed = dailyTotalReadTime >= readingGoal

                        if halfwayReached && notCompleted {
                            Text("You’re almost there, just a little more to go! Only \(readingGoal - dailyTotalReadTime) minutes stand between you and your goal!")
                                .font(.footnote)
                                .foregroundColor(.orange)
                        } else if completed {
                            Text("Well done, you did it! Congratulations on reaching your goal!")
                                .font(.footnote)
                                .foregroundColor(.green)
                        }
                    }
                    .displayConfetti(isActive: $showConfetti)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                }
                
                // All Stats
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
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                        }
                    } else {
    
                        ProgressView()
                        Text("Loading...")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                }

                VStack(alignment: .leading) {
                    Text("Weekly Reading Stats")
                        .font(.headline)
                    
                    if !weeklyStatistics.isEmpty && !days.isEmpty {
                        Chart {
                            ForEach(Array(weeklyStatistics.enumerated()), id: \.offset) { index, seconds in
                                LineMark(
                                    x: .value("Day", days[index]),
                                    y: .value("Time (hours)", Double(seconds) / 3600.0)
                                )
                                .foregroundStyle(seconds >= readingGoal * 60 ? .green : .blue)
                            }
                        }
                        .frame(height: 200)
                        .chartYAxis {
                            AxisMarks(position: .trailing) { value in
                                AxisValueLabel {
                                    if let doubleValue = value.as(Double.self) {
                                        Text(
                                            bookViewModel.formatTime(
                                                seconds: Int(
                                                    doubleValue * 3600
                                                )
                                            )
                                        )
                                    }
                                }
                            }
                        }
                        .frame(height: 200)
                    } else {
                        Chart {
                            BarMark(
                                x: .value("Day", "No Data"),
                                y: .value("Time", 0)
                            )
                            .foregroundStyle(.gray)
                        }
                        .frame(height: 200)
                        
                        Text("No data available for the past week.")
                            .font(.callout)
                            .foregroundColor(.gray)
                            .padding(.top, 5)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                
            }
            
            
            
        }
        .onAppear {
            bookViewModel.fetchWeeklyStatistics { stats in
                weeklyStatistics = stats
                days = bookViewModel.getLastSevenDays()
                
            }
            bookViewModel.updateDailyReadingTime(seconds: 0)
            bookViewModel.fetchReadingGoal { goal in
                if let goal = goal {
                    readingGoal = goal
                }
            }
            
            bookViewModel.fetchUserStatistics { statistics in
                
                userStatistics = statistics
                
                
                
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
            
            randomWelcomeMessage = WelcomeMessages.messages.randomElement() ?? "Welcome,"
            randomMotivation = MotivationQuotes.quotes.randomElement() ?? "Keep reading, keep growing!"
            authViewModel.fetchNickname { fetchedNickname in
                if let fetchedNickname = fetchedNickname {
                    nickname = "\(fetchedNickname)"
                } else {
                    nickname = "Guest"
                }
            }
            
            randomMotivation = bookViewModel.fetchDailyMotivation()
        }
        .padding(10)
    }
}


#Preview {
    HomeView(authViewModel: AuthenticationViewModel(), bookViewModel: BookViewModel())
}
