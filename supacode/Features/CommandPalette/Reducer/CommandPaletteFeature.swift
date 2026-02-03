import ComposableArchitecture
import Foundation

@Reducer
struct CommandPaletteFeature {
  @ObservableState
  struct State: Equatable {
    var isPresented = false
    var query = ""
    var items: [CommandPaletteItem] = []
    var selectedIndex: Int?

    var filteredItems: [CommandPaletteItem] {
      CommandPaletteFeature.filterItems(items: items, query: query)
    }
  }

  enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case setPresented(Bool)
    case togglePresented
    case setItems([CommandPaletteItem])
    case moveSelection(MoveDirection)
    case submitSelected
    case activateItem(CommandPaletteItem.ID)
    case activateShortcut(Int)
    case delegate(Delegate)
  }

  enum MoveDirection: Equatable {
    case up
    case down
  }

  @CasePathable
  enum Delegate: Equatable {
    case selectWorktree(Worktree.ID)
    case openSettings
    case newWorktree
    case removeWorktree(Worktree.ID, Repository.ID)
    case runWorktree(Worktree.ID)
    case openWorktreeInEditor(Worktree.ID)
  }

  var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(\.query):
        let trimmed = state.query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
          state.selectedIndex = nil
          return .none
        }
        let count = state.filteredItems.count
        if count == 0 {
          state.selectedIndex = nil
        } else if let selectedIndex = state.selectedIndex, selectedIndex >= count {
          state.selectedIndex = count - 1
        } else if state.selectedIndex == nil {
          state.selectedIndex = 0
        }
        return .none

      case .binding:
        return .none

      case .setPresented(let isPresented):
        state.isPresented = isPresented
        if isPresented {
          state.selectedIndex = nil
        } else {
          state.query = ""
          state.selectedIndex = nil
        }
        return .none

      case .togglePresented:
        state.isPresented.toggle()
        if state.isPresented {
          state.selectedIndex = nil
        } else {
          state.query = ""
          state.selectedIndex = nil
        }
        return .none

      case .setItems(let items):
        state.items = items
        let count = state.filteredItems.count
        if count == 0 {
          state.selectedIndex = nil
        } else if let selectedIndex = state.selectedIndex, selectedIndex >= count {
          state.selectedIndex = count - 1
        } else if state.selectedIndex == nil,
          !state.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        {
          state.selectedIndex = 0
        }
        return .none

      case .moveSelection(let direction):
        let count = state.filteredItems.count
        guard count > 0 else {
          state.selectedIndex = nil
          return .none
        }
        let maxIndex = count - 1
        switch direction {
        case .up:
          if let selectedIndex = state.selectedIndex {
            state.selectedIndex = selectedIndex == 0 ? maxIndex : selectedIndex - 1
          } else {
            state.selectedIndex = maxIndex
          }
        case .down:
          if let selectedIndex = state.selectedIndex {
            state.selectedIndex = selectedIndex == maxIndex ? 0 : selectedIndex + 1
          } else {
            state.selectedIndex = 0
          }
        }
        return .none

      case .submitSelected:
        let rows = state.filteredItems
        guard let selectedIndex = state.selectedIndex else { return .none }
        if rows.indices.contains(selectedIndex) {
          return activate(rows[selectedIndex], state: &state)
        }
        if let last = rows.last {
          return activate(last, state: &state)
        }
        return .none

      case .activateItem(let id):
        guard let item = state.items.first(where: { $0.id == id }) else {
          return .none
        }
        return activate(item, state: &state)

      case .activateShortcut(let index):
        let rows = state.filteredItems
        guard rows.indices.contains(index) else { return .none }
        return activate(rows[index], state: &state)

      case .delegate:
        return .none
      }
    }
  }

  static func filterItems(items: [CommandPaletteItem], query: String) -> [CommandPaletteItem] {
    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
    let globalItems = items.filter(\.isGlobal)
    guard !trimmed.isEmpty else { return globalItems }
    let worktreeItems = items.filter {
      switch $0.kind {
      case .worktreeSelect:
        return true
      case .openSettings, .newWorktree, .removeWorktree, .runWorktree, .openWorktreeInEditor:
        return false
      }
    }
    let matcher: (CommandPaletteItem) -> Bool = { $0.matches(query: trimmed) }
    return globalItems.filter(matcher) + worktreeItems.filter(matcher)
  }
}

private func activate(_ item: CommandPaletteItem, state: inout CommandPaletteFeature.State)
  -> Effect<CommandPaletteFeature.Action>
{
  state.isPresented = false
  state.query = ""
  state.selectedIndex = nil
  return .send(.delegate(delegateAction(for: item.kind)))
}

private func delegateAction(for kind: CommandPaletteItem.Kind) -> CommandPaletteFeature.Delegate {
  switch kind {
  case .worktreeSelect(let id):
    return .selectWorktree(id)
  case .openSettings:
    return .openSettings
  case .newWorktree:
    return .newWorktree
  case .removeWorktree(let worktreeID, let repositoryID):
    return .removeWorktree(worktreeID, repositoryID)
  case .runWorktree(let worktreeID):
    return .runWorktree(worktreeID)
  case .openWorktreeInEditor(let worktreeID):
    return .openWorktreeInEditor(worktreeID)
  }
}
