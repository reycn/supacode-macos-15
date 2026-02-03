import Foundation

struct CommandPaletteItem: Identifiable, Equatable {
  let id: String
  let title: String
  let subtitle: String?
  let kind: Kind

  enum Kind: Equatable {
    case worktreeSelect(Worktree.ID)
    case openSettings
    case newWorktree
    case removeWorktree(Worktree.ID, Repository.ID)
    case runWorktree(Worktree.ID)
    case openWorktreeInEditor(Worktree.ID)
  }

  var isGlobal: Bool {
    switch kind {
    case .openSettings, .newWorktree:
      return true
    case .worktreeSelect, .removeWorktree, .runWorktree, .openWorktreeInEditor:
      return false
    }
  }

  func matches(query: String) -> Bool {
    if title.localizedStandardContains(query) {
      return true
    }
    if let subtitle, subtitle.localizedStandardContains(query) {
      return true
    }
    return false
  }
}
