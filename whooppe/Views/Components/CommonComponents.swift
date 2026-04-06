import SwiftUI

// Duplicate components removed - use separate files:
// - DetailTopBar (use DetailTopBar.swift)
// - ProceedBottomBar (use ProceedBottomBar.swift)  
// - CommonTopBar (use CommonTopBar.swift)
// - CommonBottomBar (use CommonBottomBar.swift)

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    var isCenter: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                if isCenter {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#D4B547"))
                            .frame(width: 52, height: 52)
                        Image(systemName: icon)
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? Color(hex: "#D4B547") : .gray)
                    Text(title)
                        .font(.system(size: 10))
                        .foregroundColor(isSelected ? Color(hex: "#D4B547") : .gray)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct CameraScreen: View {
    let onImageCaptured: (UIImage) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var isFrontCamera = false
    
    var body: some View {
        ZStack {
            // CameraPreview implementation commented out
            Color.black
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Button(action: { isFrontCamera.toggle() }) {
                        Image(systemName: "camera.rotate")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 50)
                
                Spacer()
                
                Button(action: {
                    // Capture photo
                    let image = UIImage()
                    onImageCaptured(image)
                    dismiss()
                }) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 72, height: 72)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 64, height: 64)
                        )
                }
                .padding(.bottom, 48)
            }
        }
    }
}

// Helper extension for corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCornerShape(radius: radius, corners: corners))
    }
}

struct RoundedCornerShape: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
