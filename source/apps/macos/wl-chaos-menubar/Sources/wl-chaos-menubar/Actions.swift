import Foundation

enum ChaosCommand {
    static func run(_ args: [String]) -> Shell.Result {
        Shell.run("/Users/wonderland/Wonderland/security/operator-gate/wl-chaos-authorized-action", args)
    }
}
