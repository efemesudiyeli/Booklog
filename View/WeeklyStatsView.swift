//
//  WeeklyStatsView.swift
//  Booklog
//
//  Created by Efe Mesudiyeli on 22.01.2025.
//
import SwiftUI
import Charts

struct WeeklyStatsView: View {
    @ObservedObject var bookViewModel: BookViewModel
    @State private var weeklyStatistics: [Int] = []
    @Binding var userStatistics: [String: Any]
    @State private var days: [String] = []
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Weekly Reading Stats")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack {
                if !weeklyStatistics.isEmpty && !days.isEmpty {
                    Chart {
                        ForEach(Array(weeklyStatistics.enumerated()), id: \.offset) { index, seconds in
                            LineMark(
                                x: .value("Day", days[index]),
                                y: .value("Time (hours)", Double(seconds) / 3600.0)
                            )
                            .foregroundStyle(.white)
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
                    ZStack {
                        // Temsili LineChart
                        Chart {
                            ForEach(0..<7, id: \.self) { index in
                                LineMark(
                                    x: .value("Day", "Day \(index + 1)"),
                                    y: .value("Time", Double.random(in: 0...2))
                                )
                                .foregroundStyle(.white)
                            }
                        }
                        .frame(height: 300)
                        
                        .chartXAxis {
                            AxisMarks {  } // X eksenini gizle
                        }
                        .chartYAxis {
                            AxisMarks { } // Y eksenini gizle
                        }
                        
                        .blur(radius: 5) // Bulanıklaştırma efekti
                        
                        
                        // Bilgilendirme Metni
                        VStack {
                            Text("No data available for the past week.")
                                .font(.callout)
                                .foregroundColor(.white)
                                .padding(.top, 5)
                                .bold()
                        }
                    }
                    .frame(height: 200) // ZStack yüksekliği
                }
            }
            .padding()
            .background(Color.cSecondary)
            .cornerRadius(10)
        }
        .onAppear {
            bookViewModel.fetchWeeklyStatistics { stats in
                weeklyStatistics = stats
                days = bookViewModel.getLastSevenDays()
                
            }
        }
    }
}
