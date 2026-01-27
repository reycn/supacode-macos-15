import ComposableArchitecture
import SwiftUI

struct WorktreeDetailView: View {
  @Bindable var store: StoreOf<AppFeature>
  let terminalManager: WorktreeTerminalManager
  @Environment(CommandKeyObserver.self) private var commandKeyObserver

  var body: some View {
    detailBody(state: store.state)
  }

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
    let startSearchAction: (() -> Void)? = isOpenDisabled
      ? nil
      : { store.send(.startSearch) }
    let searchSelectionAction: (() -> Void)? = isOpenDisabled
      ? nil
      : { store.send(.searchSelection) }
    let navigateSearchNextAction: (() -> Void)? = isOpenDisabled
      ? nil
      : { store.send(.navigateSearchNext) }
    let navigateSearchPreviousAction: (() -> Void)? = isOpenDisabled
      ? nil
      : { store.send(.navigateSearchPrevious) }
    let endSearchAction: (() -> Void)? = isOpenDisabled
      ? nil
      : { store.send(.endSearch) }
    let content = Group {
      if let loadingInfo {
        WorktreeLoadingView(info: loadingInfo)
      } else if let selectedWorktree {
        let shouldRunSetupScript = repositories.pendingSetupScriptWorktreeIDs.contains(selectedWorktree.id)
        WorktreeTerminalTabsView(
          worktree: selectedWorktree,
          manager: terminalManager,
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
      openToolbar(
        isOpenDisabled: isOpenDisabled,
        openActionSelection: openActionSelection,
        showExtras: commandKeyObserver.isPressed
      )
    }
    let actions = FocusedActions(
      openSelectedWorktree: openSelectedWorktreeAction,
      newTerminal: newTerminalAction,
      closeTab: closeTabAction,
      closeSurface: closeSurfaceAction,
      startSearch: startSearchAction,
      searchSelection: searchSelectionAction,
      navigateSearchNext: navigateSearchNextAction,
      navigateSearchPrevious: navigateSearchPreviousAction,
      endSearch: endSearchAction
    )
    return applyFocusedActions(content: content, actions: actions)
  }

  private func applyFocusedActions<Content: View>(
    content: Content,
    actions: FocusedActions
  ) -> some View {
    content
      .focusedSceneValue(\.openSelectedWorktreeAction, actions.openSelectedWorktree)
      .focusedSceneValue(\.newTerminalAction, actions.newTerminal)
      .focusedSceneValue(\.closeTabAction, actions.closeTab)
      .focusedSceneValue(\.closeSurfaceAction, actions.closeSurface)
      .focusedSceneValue(\.startSearchAction, actions.startSearch)
      .focusedSceneValue(\.searchSelectionAction, actions.searchSelection)
      .focusedSceneValue(\.navigateSearchNextAction, actions.navigateSearchNext)
      .focusedSceneValue(\.navigateSearchPreviousAction, actions.navigateSearchPrevious)
      .focusedSceneValue(\.endSearchAction, actions.endSearch)
  }

  private struct FocusedActions {
    let openSelectedWorktree: (() -> Void)?
    let newTerminal: (() -> Void)?
    let closeTab: (() -> Void)?
    let closeSurface: (() -> Void)?
    let startSearch: (() -> Void)?
    let searchSelection: (() -> Void)?
    let navigateSearchNext: (() -> Void)?
    let navigateSearchPrevious: (() -> Void)?
    let endSearch: (() -> Void)?
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
    openActionSelection: OpenWorktreeAction,
    showExtras: Bool
  ) -> some ToolbarContent {
    if !isOpenDisabled {
      ToolbarItemGroup(placement: .primaryAction) {
        openMenu(openActionSelection: openActionSelection, showExtras: showExtras)
      }
    }
  }

  @ViewBuilder
  private func openMenu(openActionSelection: OpenWorktreeAction, showExtras: Bool) -> some View {
    HStack(spacing: 0) {
      Button {
        store.send(.openWorktree(openActionSelection))
      } label: {
        OpenWorktreeActionMenuLabelView(
          action: openActionSelection,
          shortcutHint: showExtras ? AppShortcuts.openFinder.display : nil
        )
      }
      .buttonStyle(.borderless)
      .padding(8)
      .help(openActionHelpText(for: openActionSelection, isDefault: true))

      Divider()
        .frame(height: 16)

      Menu {
        ForEach(OpenWorktreeAction.allCases) { action in
          let isDefault = action == openActionSelection
          Button {
            store.send(.openActionSelectionChanged(action))
            store.send(.openWorktree(action))
          } label: {
            OpenWorktreeActionMenuLabelView(action: action, shortcutHint: nil)
          }
          .buttonStyle(.plain)
          .help(openActionHelpText(for: action, isDefault: isDefault))
        }
      } label: {
        Image(systemName: "chevron.down")
          .font(.system(size: 8))
          .accessibilityLabel("Open in menu")
      }
      .buttonStyle(.borderless)
      .padding(8)
      .imageScale(.small)
      .menuIndicator(.hidden)
      .fixedSize()
      .help("Open in...")
    }
  }

  private func openActionHelpText(for action: OpenWorktreeAction, isDefault: Bool) -> String {
    isDefault
      ? "\(action.title) (\(AppShortcuts.openFinder.display))"
      : action.title
  }
}
