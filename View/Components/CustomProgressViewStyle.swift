import SwiftUI

struct CustomProgressViewStyle: ProgressViewStyle {
    var color: Color
    var progressStartString: String?
    var progressEndString: String?

    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Progress Bar Background
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)

                // Progress Bar Fill
                Capsule()
                    .fill(color)
                    .frame(
                        width: CGFloat(configuration.fractionCompleted ?? 0) * geometry.size.width,
                        height: 8
                    )

                // Start String ve Circle
                if let fraction = configuration.fractionCompleted, let startString = progressStartString, let endString = progressEndString {
                    ZStack {
                        // Circle
                        Circle()
                            .fill(color)
                            .frame(width: 12, height: 12)
                        
                     
                        

                        // Start String
                        Text("\(startString)m / \(endString)m")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: true, vertical: false)
                            .offset(y: -15) // StartString'i Circle'ın üstüne taşı
                    }
                    .position(
                        x: CGFloat(fraction) * (geometry.size.width), // Daha hassas konumlandırma
                        y: 20
                    )
                }

               
            }
        }
        .frame(height: 40)
    }
}
