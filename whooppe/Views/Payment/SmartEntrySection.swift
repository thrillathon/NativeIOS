import SwiftUI

struct SmartEntrySection: View {
    let isFaceVerified: Bool
    let isChecked: Bool
    let onChanged: (Bool) -> Void
    let onVerifyFace: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Smart Entry")
                        .font(.headline)
                    
                    Text("Fast entry with face verification")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { isFaceVerified ? true : isChecked },
                    set: { 
                        if isFaceVerified {
                            onChanged($0)
                        }
                    }
                ))
                .disabled(!isFaceVerified)
            }
            
            if !isFaceVerified {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Complete face verification to enable Smart Entry")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        
                        if let onVerifyFace = onVerifyFace {
                            Button(action: onVerifyFace) {
                                Text("Verify Now")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal, 16)
    }
}

#Preview {
    VStack(spacing: 20) {
        SmartEntrySection(
            isFaceVerified: true,
            isChecked: true,
            onChanged: { _ in },
            onVerifyFace: nil
        )
        
        SmartEntrySection(
            isFaceVerified: false,
            isChecked: false,
            onChanged: { _ in },
            onVerifyFace: { print("Verify face tapped") }
        )
    }
    .padding(16)
}
