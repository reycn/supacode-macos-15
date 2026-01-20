import Foundation

struct Worktree: Identifiable, Hashable {
    let id: UUID
    let name: String
    let detail: String
    let workingDirectory: String
}

extension Worktree {
    static let sample: [Worktree] = {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return [
            Worktree(id: UUID(), name: "khoi/tashkent", detail: "tashkent • 1h ago", workingDirectory: home),
            Worktree(id: UUID(), name: "khoi/karachi", detail: "karachi • 1h ago", workingDirectory: "/")
        ]
    }()
}
