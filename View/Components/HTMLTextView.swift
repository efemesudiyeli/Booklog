import SwiftUI

struct HTMLTextView: UIViewRepresentable {
    let htmlContent: String

    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textColor = UIColor.label
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if let data = htmlContent.data(using: .utf8) {
            do {
                let attributedString = try NSAttributedString(
                    data: data,
                    options: [.documentType: NSAttributedString.DocumentType.html,
                              .characterEncoding: String.Encoding.utf8.rawValue],
                    documentAttributes: nil
                )
                uiView.attributedText = attributedString
            } catch {
                print("HTML işlenirken hata oluştu: \(error.localizedDescription)")
                uiView.text = htmlContent
            }
        }
    }
}
