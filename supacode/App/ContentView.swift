//
//  ContentView.swift
//  supacode
//
//  Created by khoi on 20/1/26.
//

import ComposableArchitecture
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
  @Bindable var store: StoreOf<AppFeature>
  let terminalStore: WorktreeTerminalStore
  @Environment(\.scenePhase) private var scenePhase
  @State private var sidebarVisibility: NavigationSplitViewVisibility = .all

  init(store: StoreOf<AppFeature>, terminalStore: WorktreeTerminalStore) {
    self.store = store
    self.terminalStore = terminalStore
  }

  var body: some View {
    let repositoriesStore = store.scope(state: \.repositories, action: \.repositories)
    NavigationSplitView(columnVisibility: $sidebarVisibility) {
      SidebarView(store: repositoriesStore)
    } detail: {
      WorktreeDetailView(store: store, terminalStore: terminalStore)
    }
    .navigationSplitViewStyle(.balanced)
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
    .alert(store: repositoriesStore.scope(state: \.$alert, action: \.alert))
    .alert(store: store.scope(state: \.$alert, action: \.alert))
    .focusedSceneValue(\.toggleSidebarAction, toggleSidebar)
  }

  private func toggleSidebar() {
    withAnimation(.easeInOut(duration: 0.2)) {
      sidebarVisibility = sidebarVisibility == .detailOnly ? .all : .detailOnly
    }
  }
}
