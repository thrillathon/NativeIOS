import SwiftUI

struct UserDetailsSection: View {
    let userName: String
    let userEmail: String
    let userPhone: String
    let userState: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ticket Holder Details")
                .font(.headline)
                .padding(.horizontal, 16)
            
            VStack(spacing: 12) {
                DetailRow(label: "Name", value: userName)
                DetailRow(label: "Email", value: userEmail)
                DetailRow(label: "Phone", value: userPhone)
                DetailRow(label: "State", value: userState)
            }
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal, 16)
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.black)
        }
    }
}

#Preview {
    UserDetailsSection(
        userName: "John Doe",
        userEmail: "john@example.com",
        userPhone: "+91 9876543210",
        userState: "Rajasthan"
    )
}
