import SwiftUI

public enum AURA {
    public static let darkBase = Color(hex: 0x05070A)
    public static let focalAccent = Color(hex: 0xB00040)
    public static let violet = Color(hex: 0xAA00FF)
    public static let green = Color(hex: 0x00FF66)
    public static let blue = Color(hex: 0x00F0FF)
}

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: opacity
        )
    }
}
