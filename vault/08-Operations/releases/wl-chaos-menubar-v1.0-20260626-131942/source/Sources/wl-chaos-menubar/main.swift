import AppKit

let app = NSApplication.shared
let delegate = ChaosMenubarApp()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
