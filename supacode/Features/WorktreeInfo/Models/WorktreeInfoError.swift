import Foundation

nonisolated enum WorktreeInfoError: LocalizedError, Equatable {
  case noWorktree
  case gitFailure(String)
  case githubFailure(String)

  var errorDescription: String? {
    switch self {
    case .noWorktree:
      return "No worktree selected"
    case .gitFailure(let message):
      return message
    case .githubFailure(let message):
      return message
    }
  }
}
