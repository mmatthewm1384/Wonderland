import Foundation

enum ChaosTime {
    static func parse(_ value: String) -> Date? {
        let isoFractional = ISO8601DateFormatter()
        isoFractional.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        if let date = isoFractional.date(from: value) {
            return date
        }

        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime]

        if let date = iso.date(from: value) {
            return date
        }

        let normalized = value.replacingOccurrences(of: "+00:00", with: "Z")

        if let date = isoFractional.date(from: normalized) {
            return date
        }

        return iso.date(from: normalized)
    }
}
