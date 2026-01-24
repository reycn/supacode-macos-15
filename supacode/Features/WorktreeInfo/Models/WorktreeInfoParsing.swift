import Foundation

nonisolated func parseAheadBehindCounts(_ output: String) -> (behind: Int, ahead: Int)? {
  let trimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)
  if trimmed.isEmpty {
    return nil
  }
  let parts = trimmed.split { $0 == " " || $0 == "\t" }
  guard parts.count >= 2, let behind = Int(parts[0]), let ahead = Int(parts[1]) else {
    return nil
  }
  return (behind, ahead)
}

nonisolated func parseStatusCounts(_ output: String) -> (staged: Int, unstaged: Int, untracked: Int) {
  var staged = 0
  var unstaged = 0
  var untracked = 0
  for line in output.split(whereSeparator: \.isNewline) {
    let text = String(line)
    if text.hasPrefix("??") {
      untracked += 1
      continue
    }
    let chars = Array(text)
    if chars.count >= 2 {
      if chars[0] != " " {
        staged += 1
      }
      if chars[1] != " " {
        unstaged += 1
      }
    }
  }
  return (staged, unstaged, untracked)
}

nonisolated func parseDefaultBranchFromSymbolicRef(_ output: String) -> String? {
  let trimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)
  if trimmed.isEmpty {
    return nil
  }
  let parts = trimmed.split(separator: "/")
  return parts.last.map(String.init)
}

nonisolated func parseMergeTreeConflict(_ output: String) -> Bool {
  output.contains("<<<<<<<") || output.contains(">>>>>>>") || output.contains("|||||||")
}
