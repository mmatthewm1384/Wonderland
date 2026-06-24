import Foundation

struct ChaosContract: Codable {
    struct AppConfig: Codable {
        let enabled: Bool?

        let rings: Int?
        let rotation_speed: Double?
        let easing: String?
        let jitter: Double?

        let intensity: Double?
        let mode: String?
        let trail_decay: String?

        let particles: Int?
        let living_ratio: Double?
        let waste_decay: String?
        let slam_force: Double?
    }

    let version: String
    let updated_at: String
    let chaos_active: Bool
    let apps: [String: AppConfig]
}
