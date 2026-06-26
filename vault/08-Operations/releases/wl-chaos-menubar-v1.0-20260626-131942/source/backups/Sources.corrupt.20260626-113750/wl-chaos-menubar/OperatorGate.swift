import Foundation

enum OperatorGate {
    static func run(_ action: String) -> String {
        shell("\"\(WLPath.gate)\" \(action)")
    }
}
