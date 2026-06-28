import Foundation

enum ChaosExecutionGate {
    static func run(
        model: ChaosModel,
        setStatus: @escaping (String) -> Void,
        execute: @escaping (ChaosModel) -> Void
    ) {
        Task {
            ChaosDebug.log("GATE_START model=\(model.id) requiresHumanApproval=\(model.requiresHumanApproval)")
            let authorization = ChaosAuthority.authorize(model: model)

            ChaosDebug.log("GATE_AUTH_RESULT model=\(model.id) allowed=\(authorization.allowed) reason=\(authorization.reason)")

            guard authorization.allowed else {
                ChaosAudit.record(model: model, authorization: authorization, humanApproved: nil)
                await MainActor.run { setStatus("Denied: \(authorization.reason)") }
                return
            }

            var humanApproved: Bool? = nil

            if model.requiresHumanApproval {
                ChaosDebug.log("GATE_HUMAN_AUTH_REQUIRED model=\(model.id)")
                let approved = await ChaosHumanAuth.requireOperatorApproval(
                    reason: "Authorize Wonderland chaos mode: \(model.title)"
                )

                humanApproved = approved
                ChaosDebug.log("GATE_HUMAN_AUTH_RESULT model=\(model.id) approved=\(approved)")

                guard approved else {
                    let denied = ChaosAuthorization(
                        allowed: false,
                        reason: "operator authentication failed",
                        leaseID: authorization.leaseID,
                        fingerprintShort: authorization.fingerprintShort
                    )

                    ChaosAudit.record(model: model, authorization: denied, humanApproved: false)
                    await MainActor.run { setStatus("Denied: operator authentication failed") }
                    return
                }
            }

            if model.id == "cataclysm" {
                ChaosDebug.log("GATE_TYPED_CONFIRMATION_REQUIRED model=\(model.id)")

                let confirmed = await ChaosTypedConfirmation.requirePhrase(
                    title: "Cataclysm Mode",
                    message: "This will initiate the highest-level reversible chaos simulation.",
                    phrase: "CATACLYSM"
                )

                ChaosDebug.log("GATE_TYPED_CONFIRMATION_RESULT model=\(model.id) confirmed=\(confirmed)")

                guard confirmed else {
                    let denied = ChaosAuthorization(
                        allowed: false,
                        reason: "typed confirmation failed",
                        leaseID: authorization.leaseID,
                        fingerprintShort: authorization.fingerprintShort
                    )

                    ChaosAudit.record(model: model, authorization: denied, humanApproved: humanApproved)

                    await MainActor.run {
                        setStatus("Denied: typed confirmation failed")
                    }

                    return
                }
            }

            ChaosDebug.log("GATE_EXECUTE model=\(model.id)")
            ChaosAudit.record(model: model, authorization: authorization, humanApproved: humanApproved)

            await MainActor.run {
                setStatus("Running \(model.title)")
                execute(model)
            }
        }
    }
}
