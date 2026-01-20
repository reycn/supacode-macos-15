import SwiftUI

struct TerminalCommands: Commands {
    @FocusedValue(\.newTerminalAction) private var newTerminalAction

    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("New Terminal") {
                newTerminalAction?()
            }
            .keyboardShortcut(AppShortcuts.newTerminal.keyEquivalent, modifiers: AppShortcuts.newTerminal.modifiers)
            .disabled(newTerminalAction == nil)
        }
    }
}

private struct NewTerminalActionKey: FocusedValueKey {
    typealias Value = () -> Void
}

extension FocusedValues {
    var newTerminalAction: (() -> Void)? {
        get { self[NewTerminalActionKey.self] }
        set { self[NewTerminalActionKey.self] = newValue }
    }
}
