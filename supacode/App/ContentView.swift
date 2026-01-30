//
//  ContentView.swift
//  supacode
//
//  Created by khoi on 20/1/26.
//

import AppKit
import ComposableArchitecture
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
  @Bindable var store: StoreOf<AppFeature>
  let terminalManager: WorktreeTerminalManager
  @Environment(\.scenePhase) private var scenePhase
  @State private var leftSidebarVisibility: NavigationSplitViewVisibility = .all

  init(store: StoreOf<AppFeature>, terminalManager: WorktreeTerminalManager) {
    self.store = store
    self.terminalManager = terminalManager
  }

  var body: some View {
    let repositoriesStore = store.scope(state: \.repositories, action: \.repositories)
    NavigationSplitView(columnVisibility: $leftSidebarVisibility) {
      SidebarView(store: repositoriesStore, terminalManager: terminalManager)
        .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 320)
    } detail: {
      WorktreeDetailView(store: store, terminalManager: terminalManager)
    }
    .navigationSplitViewStyle(.automatic)
    .task {
      store.send(.task)
    }
    .onChange(of: scenePhase) { _, newValue in
      store.send(.scenePhaseChanged(newValue))
    }
    .fileImporter(
      isPresented: Binding(
        get: { store.repositories.isOpenPanelPresented },
        set: { store.send(.repositories(.setOpenPanelPresented($0))) }
      ),
      allowedContentTypes: [.folder],
      allowsMultipleSelection: true
    ) { result in
      switch result {
      case .success(let urls):
        store.send(.repositories(.openRepositories(urls)))
      case .failure:
        store.send(
          .repositories(
            .presentAlert(
              title: "Unable to open folders",
              message: "Supacode could not read the selected folders."
            )
          )
        )
      }
    }
    .alertWithReturnConfirm(store: repositoriesStore.scope(state: \.$alert, action: \.alert))
    .alert(store: store.scope(state: \.$alert, action: \.alert))
    .focusedSceneValue(\.toggleLeftSidebarAction, toggleLeftSidebar)
  }

  private func toggleLeftSidebar() {
    withAnimation(.easeInOut(duration: 0.2)) {
      leftSidebarVisibility = leftSidebarVisibility == .detailOnly ? .all : .detailOnly
    }
  }
}

@available(macOS 12, *)
private extension View {
  func alertWithReturnConfirm<ButtonAction>(
    store: Store<PresentationState<AlertState<ButtonAction>>, PresentationAction<ButtonAction>>
  ) -> some View {
    AlertWithReturnConfirm(content: self, store: store)
  }
}

@available(macOS 12, *)
private struct AlertWithReturnConfirm<Content: View, ButtonAction>: View {
  let content: Content
  @ObservedObject var viewStore: ViewStore<
    PresentationState<AlertState<ButtonAction>>,
    PresentationAction<ButtonAction>
  >
  @State private var keyMonitor: Any?

  init(
    content: Content,
    store: Store<PresentationState<AlertState<ButtonAction>>, PresentationAction<ButtonAction>>
  ) {
    self.content = content
    self.viewStore = ViewStore(store, observe: { $0 }, removeDuplicates: { _, _ in false })
  }

  var body: some View {
    let alertState = viewStore.state.wrappedValue
    content.alert(
      (alertState?.title).map(Text.init) ?? Text(verbatim: ""),
      isPresented: viewStore.binding(
        get: { $0.wrappedValue != nil },
        send: { _ in .dismiss }
      ),
      presenting: alertState,
      actions: { alertState in
        ForEach(Array(alertState.buttons.enumerated()), id: \.element.id) { _, button in
          alertButton(button)
        }
      },
      message: {
        $0.message.map(Text.init)
      }
    )
    .onAppear {
      guard keyMonitor == nil else { return }
      keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
        guard viewStore.state.wrappedValue != nil else { return event }
        let modifiers = event.modifierFlags.intersection([.command, .option, .control, .shift])
        guard modifiers.isEmpty else { return event }
        guard event.keyCode == 36 || event.keyCode == 76 else { return event }
        guard let button = viewStore.state.wrappedValue?.buttons.first else { return event }
        switch button.action.type {
        case let .send(action):
          if let action {
            viewStore.send(.presented(action))
          } else {
            viewStore.send(.dismiss)
          }
        case let .animatedSend(action, animation):
          if let action {
            viewStore.send(.presented(action), animation: animation)
          } else {
            viewStore.send(.dismiss)
          }
        }
        return nil
      }
    }
    .onDisappear {
      if let keyMonitor {
        NSEvent.removeMonitor(keyMonitor)
        self.keyMonitor = nil
      }
    }
  }

  @ViewBuilder
  private func alertButton(_ button: ButtonState<ButtonAction>) -> some View {
    Button(role: button.role.map(ButtonRole.init)) {
      switch button.action.type {
      case let .send(action):
        if let action {
          viewStore.send(.presented(action))
        }
      case let .animatedSend(action, animation):
        if let action {
          viewStore.send(.presented(action), animation: animation)
        }
      }
    } label: {
      Text(button.label)
    }
  }
}
