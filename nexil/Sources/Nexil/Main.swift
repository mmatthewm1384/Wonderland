import AppKit
import SwiftUI

@main
struct NexilApp {
    static func main() {
        let delegate = AppDelegate()
        NSApplication.shared.delegate = delegate
        NSApplication.shared.setActivationPolicy(.accessory)
        NSApplication.shared.run()
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let store = ClipboardStore()
    private var monitor: ClipboardMonitor!
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var popoverController: NSHostingController<NexilView>!
    private weak var previousApplication: NSRunningApplication?

    func applicationDidFinishLaunching(_ notification: Notification) {
        monitor = ClipboardMonitor(store: store)
        monitor.start()

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "square.stack.3d.up", accessibilityDescription: "Nexil")
            button.action = #selector(togglePopover)
            button.target = self
        }

        popover = NSPopover()
        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = NSSize(width: 430, height: 560)
        popoverController = NSHostingController(rootView: NexilView(store: store, paste: { [weak self] clip in self?.paste(clip) }))
        popover.contentViewController = popoverController

        HotKeyManager.shared.onPress = { [weak self] in self?.showRecall() }
        HotKeyManager.shared.register()
    }

    @objc func togglePopover() {
        if popover.isShown {
            popover.performClose(nil)
        } else {
            showPopover()
        }
    }

    private func showRecall() {
        if popover.isShown {
            popover.performClose(nil)
        } else {
            showPopover()
        }
    }

    private func showPopover() {
        previousApplication = NSWorkspace.shared.frontmostApplication
        guard let button = statusItem.button else { return }
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()
    }

    private func paste(_ clip: Clip) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(clip.text, forType: .string)
        popover.performClose(nil)

        previousApplication?.activate(options: [.activateIgnoringOtherApps])
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            let source = CGEventSource(stateID: .combinedSessionState)
            let down = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
            let up = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
            down?.flags = .maskCommand
            up?.flags = .maskCommand
            down?.post(tap: .cgAnnotatedSessionEventTap)
            up?.post(tap: .cgAnnotatedSessionEventTap)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        monitor.stop()
        HotKeyManager.shared.unregister()
    }
}

struct NexilView: View {
    @ObservedObject var store: ClipboardStore
    let paste: (Clip) -> Void
    @State private var query = ""

    private var filtered: [Clip] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return store.clips }
        return store.clips.filter {
            $0.text.localizedCaseInsensitiveContains(q) || $0.type.localizedCaseInsensitiveContains(q)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "square.stack.3d.up.fill")
                    .foregroundStyle(.cyan)
                Text("Nexil")
                    .font(.headline)
                Spacer()
                Text("⌥Space")
                    .font(.caption2.monospaced())
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search clipboard…", text: $query)
                    .textFieldStyle(.plain)
            }
            .padding(9)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 9))
            .padding(.horizontal, 12)
            .padding(.bottom, 10)

            Divider()

            if filtered.isEmpty {
                ContentUnavailableView("No clips", systemImage: "square.stack", description: Text("Copy something and Nexil will remember it."))
            } else {
                ScrollView {
                    LazyVStack(spacing: 6) {
                        ForEach(filtered) { clip in
                            ClipRow(clip: clip, paste: paste) {
                                store.togglePin(clip)
                            } delete: {
                                store.delete(clip)
                            }
                        }
                    }
                    .padding(10)
                }
            }

            Divider()
            HStack {
                Label("\(store.clips.count) stored", systemImage: "clock")
                Spacer()
                Button("Clear Unpinned") { store.clearUnpinned() }
                    .buttonStyle(.link)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(10)
        }
        .frame(width: 430, height: 560)
    }
}

struct ClipRow: View {
    let clip: Clip
    let paste: (Clip) -> Void
    let pin: () -> Void
    let delete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .frame(width: 24, height: 24)
                .foregroundStyle(.cyan)

            VStack(alignment: .leading, spacing: 5) {
                Text(clip.text.replacingOccurrences(of: "\\n", with: " "))
                    .lineLimit(3)
                    .font(.system(.body, design: clip.type == "Code" ? .monospaced : .default))
                HStack(spacing: 8) {
                    Text(clip.type)
                    Text(clip.createdAt, style: .relative)
                    if let source = clip.sourceBundleID { Text(source).lineLimit(1) }
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Menu {
                Button("Paste") { paste(clip) }
                Button(clip.pinned ? "Unpin" : "Pin") { pin() }
                Divider()
                Button("Delete", role: .destructive) { delete() }
            } label: {
                Image(systemName: clip.pinned ? "pin.fill" : "ellipsis")
                    .foregroundStyle(.secondary)
            }
            .menuStyle(.borderlessButton)
        }
        .padding(10)
        .background(.background, in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.quaternary))
        .contentShape(Rectangle())
        .onTapGesture { paste(clip) }
    }

    private var icon: String {
        switch clip.type {
        case "URL": return "link"
        case "Code": return "chevron.left.forwardslash.chevron.right"
        default: return "text.alignleft"
        }
    }
}
