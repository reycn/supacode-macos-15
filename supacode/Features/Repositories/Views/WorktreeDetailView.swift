import ComposableArchitecture
import SwiftUI

struct WorktreeDetailView: View {
  @Bindable var store: StoreOf<AppFeature>
  let terminalStore: WorktreeTerminalStore

  var body: some View {
    detailBody(state: store.state)
  }

  @ViewBuilder
  private func detailBody(state: AppFeature.State) -> some View {
    let repositories = state.repositories
    let selectedRow = repositories.selectedRow(for: repositories.selectedWorktreeID)
    let selectedWorktree = repositories.worktree(for: repositories.selectedWorktreeID)
    let loadingInfo = loadingInfo(for: selectedRow, repositories: repositories)
    let isOpenDisabled = selectedWorktree == nil || loadingInfo != nil
    let openActionSelection = state.openActionSelection
    let openSelectedWorktreeAction: (() -> Void)? = isOpenDisabled
      ? nil
      : { store.send(.openSelectedWorktree) }
    let newTerminalAction: (() -> Void)? = isOpenDisabled
      ? nil
      : { store.send(.newTerminal) }
    let closeTabAction: (() -> Void)? = isOpenDisabled
      ? nil
      : { store.send(.closeTab) }
    let closeSurfaceAction: (() -> Void)? = isOpenDisabled
      ? nil
      : { store.send(.closeSurface) }
    Group {
      if let loadingInfo {
        WorktreeLoadingView(info: loadingInfo)
      } else if let selectedWorktree {
        let shouldRunSetupScript = repositories.pendingSetupScriptWorktreeIDs.contains(selectedWorktree.id)
        WorktreeTerminalTabsView(
          worktree: selectedWorktree,
          store: terminalStore,
          shouldRunSetupScript: shouldRunSetupScript,
          createTab: { store.send(.newTerminal) }
        )
        .id(selectedWorktree.id)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
          if shouldRunSetupScript {
            store.send(.repositories(.consumeSetupScript(selectedWorktree.id)))
          }
        }
      } else {
        EmptyStateView(store: store.scope(state: \.repositories, action: \.repositories))
      }
    }
    .navigationTitle(selectedWorktree?.name ?? loadingInfo?.name ?? "Supacode")
    .toolbar {
      openToolbar(isOpenDisabled: isOpenDisabled, openActionSelection: openActionSelection)
    }
    .focusedSceneValue(\.newTerminalAction, newTerminalAction)
    .focusedSceneValue(\.closeTabAction, closeTabAction)
    .focusedSceneValue(\.closeSurfaceAction, closeSurfaceAction)
    .focusedSceneValue(\.openSelectedWorktreeAction, openSelectedWorktreeAction)
  }

  private func loadingInfo(
    for selectedRow: WorktreeRowModel?,
    repositories: RepositoriesFeature.State
  ) -> WorktreeLoadingInfo? {
    guard let selectedRow else { return nil }
    let repositoryName = repositories.repositoryName(for: selectedRow.repositoryID)
    if selectedRow.isDeleting {
      return WorktreeLoadingInfo(
        name: selectedRow.name,
        repositoryName: repositoryName,
        state: .removing
      )
    }
    if selectedRow.isPending {
      return WorktreeLoadingInfo(
        name: selectedRow.name,
        repositoryName: repositoryName,
        state: .creating
      )
    }
    return nil
  }

  @ToolbarContentBuilder
  private func openToolbar(
    isOpenDisabled: Bool,
    openActionSelection: OpenWorktreeAction
  ) -> some ToolbarContent {
    if !isOpenDisabled {
      ToolbarItemGroup(placement: .primaryAction) {
        openMenu(openActionSelection: openActionSelection)
      }
    }
  }

  @ViewBuilder
  private func openMenu(openActionSelection: OpenWorktreeAction) -> some View {
    Menu {
      ForEach(OpenWorktreeAction.allCases) { action in
        let isDefault = action == openActionSelection
        Button {
          store.send(.openActionSelectionChanged(action))
          store.send(.openWorktree(action))
        } label: {
          if let appIcon = action.appIcon {
            Label {
              Text(action.title)
            } icon: {
              Image(nsImage: appIcon)
                .accessibilityHidden(true)
            }
          } else {
            Label(action.title, systemImage: "app")
          }
        }
        .help(openActionHelpText(for: action, isDefault: isDefault))
      }
    } label: {
      Label {
        Text("Open")
      } icon: {
        if let appIcon = openActionSelection.appIcon {
          Image(nsImage: appIcon)
            .resizable()
            .scaledToFit()
            .accessibilityHidden(true)
        } else {
          Image(systemName: "folder")
            .resizable()
            .scaledToFit()
            .accessibilityHidden(true)
        }
      }
    }
    .help(openActionHelpText(for: openActionSelection, isDefault: true))
  }

  private func openActionHelpText(for action: OpenWorktreeAction, isDefault: Bool) -> String {
    isDefault
      ? "\(action.title) (\(AppShortcuts.openFinder.display))"
      : action.title
  }
}
