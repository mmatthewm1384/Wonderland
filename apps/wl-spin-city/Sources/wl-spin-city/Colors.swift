import SwiftUI

extension Color {
    static let wlBackground = Color(hex: "05070A")
    static let wlCyan = Color(hex: "00E5FF")
    static let wlPurple = Color(hex: "7000FF")
    static let wlGreen = Color(hex: "00FF66")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r = Double((int >> 16) & 0xff) / 255
        let g = Double((int >> 8) & 0xff) / 255
        let b = Double(int & 0xff) / 255

        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}
