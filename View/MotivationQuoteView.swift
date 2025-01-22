//
//  MotivationQuoteView.swift
//  Booklog
//
//  Created by Efe Mesudiyeli on 22.01.2025.
//


import SwiftUI

struct MotivationQuoteView: View {
    @State private var randomMotivation: String = ""
    @ObservedObject var bookViewModel: BookViewModel

    var body: some View {
        VStack(alignment: .center) {
            let splitMotivation = randomMotivation.split(separator: "–", maxSplits: 1, omittingEmptySubsequences: true)
            
            if splitMotivation.count == 2 {
                Text(String(splitMotivation[0])) // İlk kısım
                    .font(.callout)
                    .foregroundStyle(.white)
                    .italic()
                    .padding([.top], 8)
                
                Text(String(splitMotivation[1])) // "–" sonrası
                    .font(.callout)
                    .bold()
                    .foregroundStyle(.white)
                    .padding([.bottom], 8)
                    .frame(maxWidth: .infinity)
            } else {
                Text(randomMotivation)
                    .font(.callout)
                    .foregroundStyle(.white)
                    .italic()
                    .padding([.top, .bottom], 8)
                    .frame(maxWidth: .infinity)
            }
        }.onAppear {
            randomMotivation = bookViewModel.fetchDailyMotivation()

        }
        .padding()
        .background(.cSecondary)
        .cornerRadius(10)
    }
        
}
