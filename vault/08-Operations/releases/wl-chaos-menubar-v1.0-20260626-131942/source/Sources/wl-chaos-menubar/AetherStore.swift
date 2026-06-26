import Foundation

enum AetherStore {
    static var aether: String { ChaosStatus.load().aether }
    static var watchdog: String { ChaosStatus.load().watchdog }
}
