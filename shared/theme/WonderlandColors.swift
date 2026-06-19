import SwiftUI

public extension Color {
    static let wlBackground = Color(hex: "05070A")
    static let wlCyan = Color(hex: "00E5FF")
    static let wlPurple = Color(hex: "7000FF")
    static let wlGreen = Color(hex: "00FF66")
}

public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, ((int >> 4) & 15) * 17, (int & 15) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, (int >> 8) & 255, int & 255)
        case 8:
            (a, r, g, b) = (int >> 24, (int >> 16) & 255, (int >> 8) & 255, int & 255)
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
