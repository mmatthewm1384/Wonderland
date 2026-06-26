import AppKit

enum WLColor {
    static let cyan = NSColor(calibratedRed: 0x00/255, green: 0xE5/255, blue: 0xFF/255, alpha: 1)
    static let purple = NSColor(calibratedRed: 0x70/255, green: 0x00/255, blue: 0xFF/255, alpha: 1)
    static let green = NSColor(calibratedRed: 0x00/255, green: 0xFF/255, blue: 0x66/255, alpha: 1)
    static let amber = NSColor(calibratedRed: 0xFF/255, green: 0xB0/255, blue: 0x00/255, alpha: 1)
    static let red = NSColor(calibratedRed: 0xFF/255, green: 0x35/255, blue: 0x5E/255, alpha: 1)
}

func wlTitle(_ text: String, color: NSColor) -> NSAttributedString {
    NSAttributedString(
        string: text,
        attributes: [
            .foregroundColor: color,
            .font: NSFont.monospacedSystemFont(ofSize: 13, weight: .semibold)
        ]
    )
}
