import Foundation

enum LeaseStatus {
    case valid(String)
    case expired
    case invalid
    case missing

    var label: String {
        switch self {
        case .valid(let remaining): return "✓ VALID — \(remaining)"
        case .expired: return "⚠ EXPIRED"
        case .invalid: return "✕ INVALID"
        case .missing: return "✕ MISSING"
        }
    }
}

enum LeaseVerifier {
    static func verify() -> LeaseStatus {
        let output = shell("\"\(WLPath.gate)\" verify")

        if output.contains("PASS lease-valid") {
            return .valid(AetherStore.escalationCountdown)
        }

        if output.contains("expired") {
            return .expired
        }

        if output.contains("missing") {
            return .missing
        }

        return .invalid
    }
}
