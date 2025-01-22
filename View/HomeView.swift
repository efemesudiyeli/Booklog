
import SwiftUI

struct HomeView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    @ObservedObject var bookViewModel: BookViewModel
    @State private var userStatistics: [String: Any] = [:]
  
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                //Welcome
                WelcomeView(authViewModel: authViewModel)
                
                // Motivation
                MotivationQuoteView(bookViewModel: bookViewModel)
                
                // Daily Reading Goal
                ReadingGoalView(bookViewModel: bookViewModel)
                
                //Stats
                MyStatsView(userStatistics: $userStatistics)

                // Weekly Stats
                WeeklyStatsView(bookViewModel: bookViewModel, userStatistics: $userStatistics)
            }
        }
        .onAppear {
            bookViewModel.fetchUserStatistics { statistics in
                userStatistics = statistics
            }
        }
        .padding(10)
        .background(.cBackground)
    }
}

#Preview {
    HomeView(authViewModel: AuthenticationViewModel(), bookViewModel: BookViewModel())
}




