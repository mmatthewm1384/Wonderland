import AppKit

struct ExclusionPolicy {
    private let excludedBundleIDs: Set<String> = [
        "com.apple.keychainaccess",
        "com.1password.1password",
        "com.agilebits.onepassword4",
        "com.lastpass.LastPass",
        "com.bitwarden.desktop"
    ]

    func allowsCapture() -> Bool {
        guard let bundleID = NSWorkspace.shared.frontmostApplication?.bundleIdentifier else { return true }
        return !excludedBundleIDs.contains(bundleID)
    }
}
