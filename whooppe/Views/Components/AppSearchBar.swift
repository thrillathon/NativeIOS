import SwiftUI

struct AppSearchBar: View {
    @Binding var text: String
    let placeholder: String
    let onQueryChange: ((String) -> Void)?
    
    init(text: Binding<String>,
         placeholder: String = "SEARCH",
         onQueryChange: ((String) -> Void)? = nil) {
        self._text = text
        self.placeholder = placeholder
        self.onQueryChange = onQueryChange
    }
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .font(.system(size: 16))
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .foregroundColor(.black)
                .onChange(of: text) { newValue in
                    onQueryChange?(newValue)
                }
        }
        .padding(.horizontal, 12)
        .frame(height: 35)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: "#D4B547"), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
