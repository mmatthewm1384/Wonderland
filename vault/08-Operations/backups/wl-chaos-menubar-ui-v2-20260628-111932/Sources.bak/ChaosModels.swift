import Foundation

struct ChaosModel: Identifiable {
    let id: String
    let title: String
    let command: String
    let requiredLeaseMode: String
    let riskLevel: Int
    let reversible: Bool
    let requiresHumanApproval: Bool
}

enum ChaosModels {
    static let all: [ChaosModel] = [
        ChaosModel(id: "calm", title: "Calm", command: "status", requiredLeaseMode: "calm", riskLevel: 0, reversible: true, requiresHumanApproval: false),
        ChaosModel(id: "nudge", title: "Nudge", command: "checkin", requiredLeaseMode: "nudge", riskLevel: 1, reversible: true, requiresHumanApproval: false),
        ChaosModel(id: "drift", title: "Drift", command: "panic", requiredLeaseMode: "drift", riskLevel: 2, reversible: true, requiresHumanApproval: true),
        ChaosModel(id: "storm", title: "Storm", command: "panic", requiredLeaseMode: "storm", riskLevel: 3, reversible: true, requiresHumanApproval: true),
        ChaosModel(id: "blackout", title: "Blackout", command: "panic", requiredLeaseMode: "blackout", riskLevel: 4, reversible: true, requiresHumanApproval: true),
        ChaosModel(id: "cataclysm", title: "Cataclysm", command: "panic", requiredLeaseMode: "cataclysm", riskLevel: 5, reversible: true, requiresHumanApproval: true),
        ChaosModel(id: "recovery", title: "Recovery", command: "reset", requiredLeaseMode: "recovery", riskLevel: 0, reversible: true, requiresHumanApproval: true)
    ]

    static func find(_ id: String) -> ChaosModel? {
        all.first { $0.id == id }
    }
}
