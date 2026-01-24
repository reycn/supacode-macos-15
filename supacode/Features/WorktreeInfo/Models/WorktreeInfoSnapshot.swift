import Foundation

nonisolated struct WorktreeInfoSnapshot: Equatable {
  let repositoryName: String
  let repositoryPath: String
  let worktreePath: String
  let defaultBranchName: String?
  let workflowName: String?
  let workflowStatus: String?
  let workflowConclusion: String?
  let workflowUpdatedAt: Date?
  let githubError: String?
  let ciError: String?
}
