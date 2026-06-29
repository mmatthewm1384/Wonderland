import AppKit

public enum WonderlandEscalationPhase: Int, CaseIterable, Sendable {
    case foundation = 0
    case awareness = 1
    case attention = 2
    case transition = 3
    case pressure = 4
    case authority = 5

    public var name: String {
        switch self {
        case .foundation: "Foundation"
        case .awareness: "Awareness"
        case .attention: "Attention"
        case .transition: "Transition"
        case .pressure: "Pressure"
        case .authority: "Authority"
        }
    }

    public var hex: String {
        switch self {
        case .foundation: "#00E5FF"
        case .awareness: "#2BA7FF"
        case .attention: "#4A6BFF"
        case .transition: "#7000FF"
        case .pressure: "#C000FF"
        case .authority: "#EAF7FF"
        }
    }

    public var symbol: String {
        switch self {
        case .foundation: "◈"
        case .awareness: "◇"
        case .attention: "❖"
        case .transition: "✦"
        case .pressure: "✧"
        case .authority: "⬢"
        }
    }

    public var motion: String {
        switch self {
        case .foundation: "static"
        case .awareness: "slow_breathe"
        case .attention: "gentle_rotation"
        case .transition: "continuous_rotation"
        case .pressure: "rotation_pulse"
        case .authority: "locked"
        }
    }

    public var color: NSColor {
        switch self {
        case .foundation: NSColor(red: 0.0, green: 0.898, blue: 1.0, alpha: 1.0)
        case .awareness: NSColor(red: 0.169, green: 0.655, blue: 1.0, alpha: 1.0)
        case .attention: NSColor(red: 0.290, green: 0.420, blue: 1.0, alpha: 1.0)
        case .transition: NSColor(red: 0.439, green: 0.0, blue: 1.0, alpha: 1.0)
        case .pressure: NSColor(red: 0.753, green: 0.0, blue: 1.0, alpha: 1.0)
        case .authority: NSColor(red: 0.918, green: 0.969, blue: 1.0, alpha: 1.0)
        }
    }
}

public enum WonderlandHealthState: Sendable {
    case healthy
    case warning
    case offline

    public var color: NSColor {
        switch self {
        case .healthy: NSColor(red: 0.133, green: 0.816, blue: 0.490, alpha: 1.0)
        case .warning: NSColor(red: 1.0, green: 0.690, blue: 0.125, alpha: 1.0)
        case .offline: NSColor(red: 1.0, green: 0.302, blue: 0.310, alpha: 1.0)
        }
    }
}
