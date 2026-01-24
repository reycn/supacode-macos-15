import Testing

@testable import supacode

struct WorktreeInfoParsingTests {
  @Test func parseAheadBehindCountsHandlesTabs() {
    let result = parseAheadBehindCounts("2\t5")
    #expect(result?.behind == 2)
    #expect(result?.ahead == 5)
  }

  @Test func parseStatusCountsTracksStagedUnstagedUntracked() {
    let output = "M  A.swift\n M B.swift\n?? C.swift"
    let result = parseStatusCounts(output)
    #expect(result.staged == 1)
    #expect(result.unstaged == 1)
    #expect(result.untracked == 1)
  }

  @Test func parseMergeTreeConflictDetectsMarkers() {
    let output = "<<<<<<< HEAD\nconflict\n>>>>>>> branch"
    #expect(parseMergeTreeConflict(output))
  }

  @Test func parseDefaultBranchFromSymbolicRefHandlesOrigin() {
    let output = "refs/remotes/origin/main"
    #expect(parseDefaultBranchFromSymbolicRef(output) == "main")
  }
}
