cat > Sources/wl-chaos-menubar/Actions.swift <<'EOF'
import Foundation

enum ChaosCommand {
    static func run(_ args: [String]) -> Shell.Result {
        Shell.run(Paths.authorizedAction, args)
    }
}
EOF
