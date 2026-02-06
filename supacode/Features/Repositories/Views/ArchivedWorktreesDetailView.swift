import ComposableArchitecture
import SwiftUI

struct ArchivedWorktreesDetailView: View {
  @Bindable var store: StoreOf<RepositoriesFeature>
  @State private var collapsedRepositoryIDs: Set<Repository.ID> = []

  var body: some View {
    let groups = store.state.archivedWorktreesByRepository()
    let groupIDs = Set(groups.map(\.repository.id))
    if groups.isEmpty {
      ContentUnavailableView(
        "Archived Worktrees",
        systemImage: "archivebox",
        description: Text("Archive worktrees to keep them out of the main list.")
      )
    } else {
      List {
        ForEach(groups, id: \.repository.id) { group in
          Section {
            if !collapsedRepositoryIDs.contains(group.repository.id) {
              ForEach(group.worktrees) { worktree in
                ArchivedWorktreeRowView(
                  worktree: worktree,
                  info: store.state.worktreeInfo(for: worktree.id),
                  onUnarchive: {
                    store.send(.unarchiveWorktree(worktree.id))
                  },
                  onDelete: {
                    store.send(.requestDeleteWorktree(worktree.id, group.repository.id))
                  }
                )
              }
            }
          } header: {
            ArchivedWorktreeSectionHeader(
              name: group.repository.name,
              worktreeCount: group.worktrees.count,
              isCollapsed: collapsedRepositoryIDs.contains(group.repository.id),
              onToggle: { toggleSection(group.repository.id) }
            )
          }
        }
      }
      .listStyle(.sidebar)
      .onChange(of: groupIDs) { _, newValue in
        collapsedRepositoryIDs = collapsedRepositoryIDs.intersection(newValue)
      }
    }
  }

  private func toggleSection(_ repositoryID: Repository.ID) {
    withAnimation(.easeOut(duration: 0.2)) {
      if collapsedRepositoryIDs.contains(repositoryID) {
        collapsedRepositoryIDs.remove(repositoryID)
      } else {
        collapsedRepositoryIDs.insert(repositoryID)
      }
    }
  }
}

private struct ArchivedWorktreeSectionHeader: View {
  let name: String
  let worktreeCount: Int
  let isCollapsed: Bool
  let onToggle: () -> Void

  var body: some View {
    Button {
      onToggle()
    } label: {
      HStack(spacing: 6) {
        Image(systemName: "chevron.right")
          .font(.caption2)
          .rotationEffect(.degrees(isCollapsed ? 0 : 90))
          .foregroundStyle(.secondary)
          .accessibilityHidden(true)
        Text(name)
          .foregroundStyle(.primary)
        Spacer()
        Text("\(worktreeCount)")
          .monospacedDigit()
          .foregroundStyle(.secondary)
      }
      .contentShape(.rect)
    }
    .buttonStyle(.plain)
    .help(isCollapsed ? "Expand repository section" : "Collapse repository section")
    .textCase(nil)
  }
}
