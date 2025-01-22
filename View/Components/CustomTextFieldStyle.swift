import SwiftUI

/// Custom TextFieldStyle with SF Symbol
struct CustomTextFieldStyle: TextFieldStyle {
    var backgroundColor: Color = .cDarkest
    var borderColor: Color = .gray
    var cornerRadius: CGFloat = 10
    var paddingVertical: CGFloat = 16
    var iconName: String? = nil // SF Symbol adı

    func _body(configuration: TextField<_Label>) -> some View {
        HStack() {
            
            // SF Symbol
            if let iconName = iconName {
                Image(systemName: iconName)
                    .padding(.leading, 14)
                    .frame(width: 20, height: 20)
                    .alignmentGuide(HorizontalAlignment.center) {
                        $0[HorizontalAlignment.center]
                    }
                    
            }  
            // TextField
            configuration
                .padding(.vertical, paddingVertical)
                .padding(.leading, 10)
                .foregroundStyle(.white)
            
            
        }
        .foregroundStyle(.cBackground)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(borderColor, lineWidth: 0.5) // Çerçeve
                .opacity(0.5)
        )
        .padding(.horizontal)
    }
}

#Preview(body: {
    TextField("Deneme", text: .constant("email"))
        .textFieldStyle(CustomTextFieldStyle())
})
