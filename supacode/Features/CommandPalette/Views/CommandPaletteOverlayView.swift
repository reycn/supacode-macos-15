import ComposableArchitecture
import SwiftUI

private typealias MoveDirection = CommandPaletteFeature.MoveDirection

struct CommandPaletteOverlayView: View {
  @Bindable var store: StoreOf<CommandPaletteFeature>
  @FocusState private var isQueryFocused: Bool
  @State private var hoveredID: CommandPaletteItem.ID?

  var body: some View {
    if store.isPresented {
      ZStack(alignment: .top) {
        Button {
          store.send(.setPresented(false))
        } label: {
          Color.clear
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(.rect)
        .accessibilityHidden(true)

        CommandPaletteCard(
          query: $store.query,
          selectedIndex: $store.selectedIndex,
          items: store.filteredItems,
          hoveredID: $hoveredID,
          isQueryFocused: $isQueryFocused,
          onEvent: { event in
            switch event {
            case .exit:
              store.send(.setPresented(false))
            case .submit:
              store.send(.submitSelected)
            case .move(let direction):
              store.send(.moveSelection(direction))
            }
          },
          activateShortcut: { index in
            store.send(.activateShortcut(index))
          },
          activate: { id in
            store.send(.activateItem(id))
          }
        )
        .padding()
      }
      .ignoresSafeArea()
      .onChange(of: store.isPresented) { _, newValue in
        isQueryFocused = newValue
        if !newValue {
          hoveredID = nil
        }
      }
      .task {
        isQueryFocused = true
      }
    }
  }
}

private struct CommandPaletteCard: View {
  @Binding var query: String
  @Binding var selectedIndex: Int?
  let items: [CommandPaletteItem]
  @Binding var hoveredID: CommandPaletteItem.ID?
  @FocusState.Binding var isQueryFocused: Bool
  let onEvent: (CommandPaletteKeyboardEvent) -> Void
  let activateShortcut: (Int) -> Void
  let activate: (CommandPaletteItem.ID) -> Void

  var body: some View {
    VStack {
      CommandPaletteQueryField(query: $query, isQueryFocused: _isQueryFocused) { event in
        onEvent(event)
      }

      Divider()

      CommandPaletteShortcutHandler(count: min(5, items.count)) { index in
        activateShortcut(index)
      }

      CommandPaletteList(
        rows: items,
        selectedIndex: $selectedIndex,
        hoveredID: $hoveredID
      ) { id in
        activate(id)
      }
    }
    .frame(maxWidth: 520)
    .background(.regularMaterial)
    .clipShape(.rect(cornerRadius: 12, style: .continuous))
    .overlay(
      RoundedRectangle(cornerRadius: 12, style: .continuous)
        .stroke(.quaternary, lineWidth: 1)
    )
    .shadow(radius: 24)
  }
}

private struct CommandPaletteQueryField: View {
  @Binding var query: String
  @FocusState.Binding var isQueryFocused: Bool
  var onEvent: (CommandPaletteKeyboardEvent) -> Void

  var body: some View {
    ZStack {
      TextField("Search...", text: $query)
        .textFieldStyle(.plain)
        .padding()
        .font(.title3)
        .focused($isQueryFocused)
        .onExitCommand { onEvent(.exit) }
        .onMoveCommand {
          switch $0 {
          case .up:
            onEvent(.move(.up))
          case .down:
            onEvent(.move(.down))
          default:
            break
          }
        }
        .onSubmit { onEvent(.submit) }
    }
  }
}

private enum CommandPaletteKeyboardEvent: Equatable {
  case exit
  case submit
  case move(MoveDirection)
}

private struct CommandPaletteList: View {
  let rows: [CommandPaletteItem]
  @Binding var selectedIndex: Int?
  @Binding var hoveredID: CommandPaletteItem.ID?
  let activate: (CommandPaletteItem.ID) -> Void

  var body: some View {
    if rows.isEmpty {
      Text("No matches")
        .foregroundStyle(.secondary)
        .padding()
    } else {
      ScrollViewReader { proxy in
        ScrollView {
          VStack {
            ForEach(rows.enumerated(), id: \.element.id) { index, row in
              CommandPaletteRowView(
                row: row,
                shortcutIndex: index < 5 ? index : nil,
                isSelected: isRowSelected(index: index),
                hoveredID: $hoveredID
              ) {
                activate(row.id)
              }
              .id(row.id)
            }
          }
          .padding()
        }
        .frame(maxHeight: 240)
        .scrollIndicators(.hidden)
        .onChange(of: selectedIndex) { _, _ in
          guard let selectedIndex, rows.indices.contains(selectedIndex) else { return }
          proxy.scrollTo(rows[selectedIndex].id)
        }
      }
    }
  }

  private func isRowSelected(index: Int) -> Bool {
    guard let selectedIndex else { return false }
    if selectedIndex < rows.count {
      return selectedIndex == index
    }
    return index == rows.count - 1
  }
}

private struct CommandPaletteRowView: View {
  let row: CommandPaletteItem
  let shortcutIndex: Int?
  let isSelected: Bool
  @Binding var hoveredID: CommandPaletteItem.ID?
  let activate: () -> Void

  var body: some View {
    Button(action: activate) {
      HStack {
        VStack(alignment: .leading) {
          Text(row.title)
            .foregroundStyle(.primary)
          if let subtitle = row.subtitle, !subtitle.isEmpty {
            Text(subtitle)
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        }

        Spacer()

        if let shortcutIndex {
          ShortcutHintView(
            text: commandPaletteShortcutDisplay(for: shortcutIndex),
            color: .secondary
          )
          .monospaced()
        }
      }
      .padding()
      .background(rowBackground)
      .clipShape(.rect(cornerRadius: 8, style: .continuous))
    }
    .buttonStyle(.plain)
    .help(helpText)
    .onHover { hovering in
      hoveredID = hovering ? row.id : nil
    }
  }

  private var rowBackground: some View {
    Group {
      if isSelected {
        Color.accentColor.opacity(0.2)
      } else if hoveredID == row.id {
        Color.secondary.opacity(0.15)
      } else {
        Color.clear
      }
    }
  }

  private var helpText: String {
    let base: String
    switch row.kind {
    case .worktreeSelect:
      base = "Switch to \(row.title)"
    case .openSettings:
      base = "Open Settings"
    case .newWorktree:
      base = "New Worktree"
    case .removeWorktree:
      base = "Remove \(row.title)"
    case .runWorktree:
      base = "Run \(row.title)"
    case .openWorktreeInEditor:
      base = "Open \(row.title) in Editor"
    }
    if let shortcutIndex {
      return "\(base) (\(commandPaletteShortcutDisplay(for: shortcutIndex)))"
    }
    return base
  }
}

private struct CommandPaletteShortcutHandler: View {
  let count: Int
  let activate: (Int) -> Void

  var body: some View {
    Group {
      if count >= 1 {
        shortcutButton(index: 0)
      }
      if count >= 2 {
        shortcutButton(index: 1)
      }
      if count >= 3 {
        shortcutButton(index: 2)
      }
      if count >= 4 {
        shortcutButton(index: 3)
      }
      if count >= 5 {
        shortcutButton(index: 4)
      }
    }
    .frame(width: 0, height: 0)
    .accessibilityHidden(true)
  }

  private func shortcutButton(index: Int) -> some View {
    Button {
      activate(index)
    } label: {
      Color.clear
    }
    .buttonStyle(.plain)
    .keyboardShortcut(KeyEquivalent(Character(String(index + 1))), modifiers: .command)
  }
}

private func commandPaletteShortcutDisplay(for index: Int) -> String {
  "Cmd+\(index + 1)"
}
