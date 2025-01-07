//
//  CustomTextFieldStyle.swift
//  Booklog
//
//  Created by Efe Mesudiyeli on 6.12.2024.
//
import SwiftUI

/// Custom TextFieldStyle
struct CustomTextFieldStyle: TextFieldStyle {
    var backgroundColor: Color = .white
    var borderColor: Color = .gray
    var cornerRadius: CGFloat = 10
    var paddingVertical: CGFloat = 25.0
    var paddingHorizontal: CGFloat = 15.0
    
    // Bu fonksiyonu düzenleyerek metin alanı ve başlık yerleşimini değiştiriyoruz
    func _body(configuration: TextField<_Label>) -> some View {
        VStack(alignment: .leading, spacing: 5) {
           
            
            // TextField - Gri renkli arka plan ve alt kısımda
            configuration
                .padding(.vertical, paddingVertical) // İç padding
                .padding(.horizontal, paddingHorizontal) // İç padding
                .background(Color.backgroundBright) // Gri arka plan
                .cornerRadius(cornerRadius)
                .overlay(
                    UnevenRoundedRectangle(topLeadingRadius: cornerRadius, bottomLeadingRadius: cornerRadius, bottomTrailingRadius: cornerRadius)
                        .stroke(borderColor, lineWidth: 0) // Kenarlık
                )
                .padding(.horizontal)
        }
    }
}


