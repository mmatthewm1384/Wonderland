import Foundation

struct SecretPolicy {
    enum Decision: Equatable {
        case store
        case reject
    }

    var enabled = true

    func evaluate(_ text: String) -> Decision {
        guard enabled else { return .store }
        let patterns = [
            #"-----BEGIN [A-Z ]*PRIVATE KEY-----"#,
            #"\bgh[pousr]_[A-Za-z0-9_]{20,}\b"#,
            #"\bAKIA[0-9A-Z]{16}\b"#,
            #"\b(?:sk|pk)_(?:live|test)_[A-Za-z0-9]{16,}\b"#
        ]
        for pattern in patterns {
            if text.range(of: pattern, options: .regularExpression) != nil {
                return .reject
            }
        }
        return .store
    }
}
