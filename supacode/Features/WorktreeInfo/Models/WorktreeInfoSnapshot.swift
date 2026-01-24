import Foundation

nonisolated struct WorktreeInfoSnapshot: Equatable {
  let repositoryName: String
  let repositoryPath: String
  let worktreePath: String
  let branchName: String
  let isDetachedHead: Bool
  let defaultBranchName: String?
  let aheadOfDefault: Int?
  let behindDefault: Int?
  let outOfDateWithDefault: Bool?
  let upstreamBranchName: String?
  let aheadOfUpstream: Int?
  let behindUpstream: Int?
  let remoteBranchExists: Bool?
  let hasUncommittedChanges: Bool
  let stagedChanges: Int
  let unstagedChanges: Int
  let untrackedChanges: Int
  let stashCount: Int
  let lastCommitSubject: String?
  let lastCommitDate: Date?
  let mergeConflictPossible: Bool?
  let pullRequestNumber: Int?
  let pullRequestTitle: String?
  let pullRequestState: String?
  let pullRequestIsDraft: Bool
  let pullRequestReviewDecision: String?
  let pullRequestUpdatedAt: Date?
  let workflowName: String?
  let workflowStatus: String?
  let workflowConclusion: String?
  let workflowUpdatedAt: Date?
  let githubError: String?
  let ciError: String?
}
