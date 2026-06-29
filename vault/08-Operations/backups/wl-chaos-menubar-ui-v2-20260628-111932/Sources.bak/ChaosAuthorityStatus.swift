import Foundation
import LocalAuthentication

struct ChaosAuthorityStatus {
    let fingerprintLine: String
    let leaseLine: String
    let authLine: String
    let leaseMode: String
    let leaseRemaining: String
}

enum ChaosAuthorityStatusReader {
    static func load() -> ChaosAuthorityStatus {
        let auth = touchIDStatus()
        let root = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Wonderland")
        let fingerprintURL = root.appendingPathComponent("vault/chaos/menubar-fingerprint.json")
        let leaseURL = root.appendingPathComponent("vault/05-Registry/chaos/lease.json")

        var fingerprintLine = "🔴 Fingerprint Missing"
        var leaseLine = "🔴 Lease Missing"
        var leaseMode = "none"
        var leaseRemaining = "expired"

        if let fp = try? JSONDecoder().decode(
            ChaosFingerprint.self,
            from: Data(contentsOf: fingerprintURL)
        ) {
            if fp.status == "active" {
                fingerprintLine = "🟢 Fingerprint \(fp.fingerprint_short)"
            } else {
                fingerprintLine = "🔴 Fingerprint Inactive"
            }
        }

        if let lease = try? JSONDecoder().decode(
            ChaosLease.self,
            from: Data(contentsOf: leaseURL)
        ) {
            leaseMode = lease.mode

            if let expires = ChaosTime.parse(lease.expires_at) {
                let remaining = Int(expires.timeIntervalSince(Date()))

                if lease.status != "active" {
                    leaseLine = "🔴 Lease Inactive"
                    leaseRemaining = "inactive"
                } else if remaining <= 0 {
                    leaseLine = "🔴 Lease Expired"
                    leaseRemaining = "expired"
                } else {
                    leaseRemaining = formatRemaining(remaining)
                    leaseLine = "🟢 Lease \(lease.mode) · \(leaseRemaining)"
                }
            } else {
                leaseLine = "🔴 Lease Invalid Time"
                leaseRemaining = "invalid"
            }
        }

        return ChaosAuthorityStatus(
            fingerprintLine: fingerprintLine,
            leaseLine: leaseLine,
            authLine: auth,
            leaseMode: leaseMode,
            leaseRemaining: leaseRemaining
        )
    }

    private static func touchIDStatus() -> String {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            return "🟢 Touch ID Ready"
        }

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            return "🟡 Password Auth Ready"
        }

        return "🔴 Operator Auth Unavailable"
    }

    private static func formatRemaining(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60

        if minutes >= 60 {
            let hours = minutes / 60
            let remMinutes = minutes % 60
            return "\(hours)h \(remMinutes)m"
        }

        if minutes > 0 {
            return "\(minutes)m \(secs)s"
        }

        return "\(secs)s"
    }
}
