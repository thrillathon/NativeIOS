import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct BlinkColors {
    struct Brand {
        static let OliveYellow = Color(hex: "#D4B547")
        static let GoldYellow = Color(hex: "#D4B547")
        static let Orange = Color(hex: "#FF6B35")
        static let LightBeige = Color(hex: "#F5F5F0")
        static let LightCream = Color(hex: "#F5F5F0")
        static let DarkGold = Color(hex: "#C4A43A")
        static let DarkerGold = Color(hex: "#B8942E")
        static let DarkestGold = Color(hex: "#A88522")
    }
    
    struct Text {
        static let Primary = Color(hex: "#333333")
        static let Secondary = Color(hex: "#666666")
        static let Tertiary = Color(hex: "#999999")
        static let Gray = Color(hex: "#888888")
        static let DarkGray = Color(hex: "#444444")
        static let Placeholder = Color(hex: "#AAAAAA")
        static let PlaceholderLight = Color(hex: "#CCCCCC")
        static let DisabledDark = Color(hex: "#999999")
        static let DisabledLight = Color(hex: "#CCCCCC")
        static let Transparent50 = Color(hex: "#888888")
        static let SemiTransparent = Color(hex: "#AAAAAA")
    }
    
    struct Background {
        static let White = Color.white
        static let LightBg = Color(hex: "#F5F5F0")
        static let SelectedState = Color(hex: "#FFF8E7")
        static let PlaceholderGray = Color(hex: "#E5E5E5")
        static let LightGray = Color(hex: "#E5E5E5")
        static let DisabledLight = Color(hex: "#F0F0F0")
        static let Card = Color.white
        static let WarningLight = Color(hex: "#FFF3E0")
    }
    
    struct Border {
        static let LightGray = Color(hex: "#E5E5E5")
        static let Gold = Color(hex: "#D4B547")
        static let Black = Color.black
        static let BlackDisabled = Color(hex: "#CCCCCC")
    }
    
    struct Divider {
        static let Dark = Color(hex: "#D9D9D9")
        static let Light = Color(hex: "#E5E5E5")
        static let Subtle = Color(hex: "#E0E0E0")
    }
    
    struct Status {
        static let Info = Color(hex: "#2196F3")
        static let Error = Color(hex: "#F44336")
        static let ErrorAlt = Color(hex: "#E53935")
        static let Cyan = Color(hex: "#03A9F4")
        static let LightBlue = Color(hex: "#03A9F4")
        static let UpcomingBg = Color(hex: "#E3F2FD")
        static let UpcomingBorder = Color(hex: "#90CAF9")
    }
    
    struct IndiaFlag {
        static let Saffron = Color(hex: "#FF9933")
        static let White = Color.white
        static let Green = Color(hex: "#138808")
        static let NavyBlue = Color(hex: "#000080")
    }
}
