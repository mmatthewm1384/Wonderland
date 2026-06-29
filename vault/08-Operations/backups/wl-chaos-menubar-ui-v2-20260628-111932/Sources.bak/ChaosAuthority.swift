import Foundation

struct ChaosFingerprint: Decodable {
    let fingerprint_id: String
    let fingerprint_short: String
    let scope: String
    let status: String
}

struct ChaosLease: Decodable {
    let schema: String
    let lease_id: String
    let operatorName: String?
    let scope: String
    let mode: String
    let issued_at: String
    let expires_at: String
    let fingerprint_id: String
    let fingerprint_short: String
    let status: String

    enum CodingKeys: String, CodingKey {
        case schema
        case lease_id
        case operatorName = "operator"
        case scope
        case mode
        case issued_at
        case expires_at
        case fingerprint_id
        case fingerprint_short
        case status
    }
}

struct ChaosAuthorization {
    let allowed: Bool
    let reason: String
    let leaseID: String?
    let fingerprintShort: String?
}

enum ChaosAuthority {
    static let root = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Wonderland")
    static let fingerprintURL = root.appendingPathComponent("vault/chaos/menubar-fingerprint.json")
    static let leaseURL = root.appendingPathComponent("vault/05-Registry/chaos/lease.json")

    static func authorize(model: ChaosModel) -> ChaosAuthorization {
        do {
            let fingerprint = try readJSON(ChaosFingerprint.self, from: fingerprintURL)
            let lease = try readJSON(ChaosLease.self, from: leaseURL)

            guard fingerprint.status == "active" else {
                return deny("fingerprint inactive", fingerprint.fingerprint_short, lease.lease_id)
            }

            guard fingerprint.scope == "chaos.menubar" else {
                return deny("fingerprint scope mismatch", fingerprint.fingerprint_short, lease.lease_id)
            }

            guard lease.schema == "wonderland.chaos.lease.v1" else {
                return deny("lease schema invalid", fingerprint.fingerprint_short, lease.lease_id)
            }

            guard lease.status == "active" else {
                return deny("lease inactive", fingerprint.fingerprint_short, lease.lease_id)
            }

            guard lease.scope == "chaos.menubar" else {
                return deny("lease scope mismatch", fingerprint.fingerprint_short, lease.lease_id)
            }

            guard lease.mode == model.requiredLeaseMode else {
                return deny("lease mode mismatch: expected \(model.requiredLeaseMode), got \(lease.mode)", fingerprint.fingerprint_short, lease.lease_id)
            }

            guard lease.fingerprint_id == fingerprint.fingerprint_id else {
                return deny("lease fingerprint mismatch", fingerprint.fingerprint_short, lease.lease_id)
            }

            guard let expires = ChaosTime.parse(lease.expires_at) else {
                return deny("lease expiration invalid", fingerprint.fingerprint_short, lease.lease_id)
            }

            guard Date() < expires else {
                return deny("lease expired", fingerprint.fingerprint_short, lease.lease_id)
            }

            return ChaosAuthorization(
                allowed: true,
                reason: "authorized",
                leaseID: lease.lease_id,
                fingerprintShort: fingerprint.fingerprint_short
            )
        } catch {
            return ChaosAuthorization(
                allowed: false,
                reason: "authority read failed: \(error.localizedDescription)",
                leaseID: nil,
                fingerprintShort: nil
            )
        }
    }

    private static func readJSON<T: Decodable>(_ type: T.Type, from url: URL) throws -> T {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }

    private static func deny(_ reason: String, _ fingerprint: String?, _ leaseID: String?) -> ChaosAuthorization {
        ChaosAuthorization(
            allowed: false,
            reason: reason,
            leaseID: leaseID,
            fingerprintShort: fingerprint
        )
    }
}
