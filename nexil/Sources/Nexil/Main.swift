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
    let store = NexilStore()
    private var monitor: ClipboardMonitor!
    private var retentionTimer: Timer?
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var popoverController: NSHostingController<NexilView>!
    private var previousApplication: NSRunningApplication?

    func applicationDidFinishLaunching(_ notification: Notification) {
        monitor = ClipboardMonitor(store: store)
        monitor.start()
        retentionTimer = Timer.scheduledTimer(withTimeInterval: 15 * 60, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.store.purgeExpired()
            }
        }
        if let retentionTimer {
            RunLoop.main.add(retentionTimer, forMode: .common)
        }

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "square.stack.3d.up", accessibilityDescription: "Nexil")
            button.action = #selector(togglePopover)
            button.target = self
        }

        popover = NSPopover()
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 430, height: 560)
        popoverController = NSHostingController(
            rootView: NexilView(store: store, paste: { [weak self] object in self?.paste(object) })
        )
        popover.contentViewController = popoverController

        HotKeyManager.shared.onPress = { [weak self] in self?.toggleRecall() }
        HotKeyManager.shared.register()
    }

    @objc private func togglePopover() { toggleRecall() }

    private func toggleRecall() {
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

    private func paste(_ object: ClipboardObject) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        if !object.fileURLs.isEmpty {
            let urls = object.fileURLs.map { URL(fileURLWithPath: $0) }
            pasteboard.writeObjects(urls as [NSURL])
        } else if object.kind == .image, let payload = object.payload {
            pasteboard.setData(payload, forType: .png)
        } else if object.kind == .richText, let payload = object.payload {
            pasteboard.setData(payload, forType: .rtf)
            if let text = object.text { pasteboard.setString(text, forType: .string) }
        } else if let text = object.text {
            pasteboard.setString(text, forType: .string)
        }

        popover.performClose(nil)
        previousApplication?.activate(options: [])
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
        retentionTimer?.invalidate()
        HotKeyManager.shared.unregister()
    }
}

struct NexilView: View {
    @ObservedObject var store: NexilStore
    let paste: (ClipboardObject) -> Void
    @State private var query = ""
    @State private var selectedIndex = 0
    @FocusState private var searchFocused: Bool

    private var filtered: [ClipboardObject] { store.search(query) }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "square.stack.3d.up.fill").foregroundStyle(.cyan)
                Text("Nexil").font(.headline)
                Spacer()
                Text("⌥Space").font(.caption2.monospaced()).foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Search clipboard…", text: $query)
                    .textFieldStyle(.plain)
                    .focused($searchFocused)
                    .onSubmit { pasteSelected() }
            }
            .padding(9)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 9))
            .padding(.horizontal, 12)
            .padding(.bottom, 10)

            Divider()
            if filtered.isEmpty {
                ContentUnavailableView(
                    "No clips",
                    systemImage: "square.stack",
                    description: Text("Copy something and Nexil will remember it.")
                )
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 6) {
                            ForEach(Array(filtered.enumerated()), id: \.element.id) { index, object in
                                ClipRow(
                                    object: object,
                                    selected: index == selectedIndex,
                                    paste: paste,
                                    pin: { store.togglePin(object) },
                                    delete: { store.delete(object) }
                                )
                                .id(object.id)
                                .onTapGesture {
                                    selectedIndex = index
                                    paste(object)
                                }
                            }
                        }
                        .padding(10)
                    }
                    .onChange(of: selectedIndex) { _, index in
                        guard filtered.indices.contains(index) else { return }
                        proxy.scrollTo(filtered[index].id, anchor: .center)
                    }
                }
            }
            Divider()
            HStack {
                Label("\(store.objects.count) stored", systemImage: "clock")
                Spacer()
                Text("↑↓ navigate  Return paste  Esc close")
                    .font(.caption2.monospaced())
                    .foregroundStyle(.secondary)
                Button("Clear Unpinned") { store.clearUnpinned() }.buttonStyle(.link)
                Button("Quit") { NSApplication.shared.terminate(nil) }.buttonStyle(.link)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(10)
        }
        .frame(width: 430, height: 560)
        .onAppear {
            selectedIndex = 0
            searchFocused = true
        }
        .onChange(of: query) { _, _ in
            selectedIndex = 0
        }
        .onChange(of: filtered.count) { _, count in
            if count == 0 {
                selectedIndex = 0
            } else if selectedIndex >= count {
                selectedIndex = count - 1
            }
        }
        .onMoveCommand { direction in
            guard !filtered.isEmpty else { return }
            switch direction {
            case .down:
                selectedIndex = min(selectedIndex + 1, filtered.count - 1)
            case .up:
                selectedIndex = max(selectedIndex - 1, 0)
            default:
                break
            }
        }
        .onExitCommand {
            NSApplication.shared.keyWindow?.performClose(nil)
        }
    }

    private func pasteSelected() {
        guard filtered.indices.contains(selectedIndex) else { return }
        paste(filtered[selectedIndex])
    }
}

struct ClipRow: View {
    let object: ClipboardObject
    let selected: Bool
    let paste: (ClipboardObject) -> Void
    let pin: () -> Void
    let delete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon).frame(width: 24, height: 24).foregroundStyle(.cyan)
            VStack(alignment: .leading, spacing: 5) {
                Text(object.previewText.replacingOccurrences(of: "\n", with: " "))
                    .lineLimit(3)
                    .font(.system(.body, design: object.kind == .code ? .monospaced : .default))
                HStack(spacing: 8) {
                    Text(object.kind.rawValue)
                    Text(object.createdAt, style: .relative)
                    if let source = object.sourceApplicationName { Text(source).lineLimit(1) }
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
            Spacer()
            Menu {
                Button("Paste") { paste(object) }
                Button(object.pinned ? "Unpin" : "Pin") { pin() }
                Divider()
                Button("Delete", role: .destructive) { delete() }
            } label: {
                Image(systemName: object.pinned ? "pin.fill" : "ellipsis")
                    .foregroundStyle(.secondary)
            }
            .menuStyle(.borderlessButton)
        }
        .padding(10)
        .background(selected ? Color.accentColor.opacity(0.12) : Color.clear, in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(selected ? Color.accentColor.opacity(0.55) : Color.clear))
        .contentShape(Rectangle())
        .onTapGesture { paste(object) }
    }

    private var icon: String {
        switch object.kind {
        case .url: "link"
        case .code: "chevron.left.forwardslash.chevron.right"
        case .image: "photo"
        case .file: "doc"
        case .richText: "textformat"
        case .text: "text.alignleft"
        }
    }
}
