cat > Sources/wl-chaos-menubar/Paths.swift <<'EOF'
import Foundation

enum Paths {
    static let wlHome = "/Users/wonderland/Wonderland"
    static let statusAdapter = "\(wlHome)/bin/wl-chaos-menubar-status"
    static let authorizedAction = "\(wlHome)/security/operator-gate/wl-chaos-authorized-action"
    static let chaosVault = "\(wlHome)/vault/chaos"
    static let operatorGate = "\(wlHome)/security/operator-gate"
}
EOF
