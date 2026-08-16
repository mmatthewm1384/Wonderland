import AppKit
import Carbon.HIToolbox

@MainActor
final class HotKeyManager {
    static let shared = HotKeyManager()
    private var hotKeyRef: EventHotKeyRef?
    private var handlerInstalled = false
    var onPress: (() -> Void)?

    func register() {
        guard hotKeyRef == nil else { return }
        var hotKeyID = EventHotKeyID(signature: OSType(0x4E584C31), id: 1)
        let modifiers = UInt32(optionKey)
        RegisterEventHotKey(UInt32(kVK_Space), modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
        guard !handlerInstalled else { return }
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallApplicationEventHandler({ _, _, _ in
            Task { @MainActor in HotKeyManager.shared.onPress?() }
            return noErr
        }, 1, &eventType, nil, nil)
        handlerInstalled = true
    }

    func unregister() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
    }
}
