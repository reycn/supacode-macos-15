//
//  ContentView.swift
//  supacode
//
//  Created by khoi on 20/1/26.
//

import SwiftUI

struct ContentView: View {
    let runtime: GhosttyRuntime
    @State private var selectedWorktreeID: Worktree.ID?
    @StateObject private var terminalStore: GhosttyTerminalStore
    private let worktrees: [Worktree] = Worktree.sample

    init(runtime: GhosttyRuntime) {
        self.runtime = runtime
        _terminalStore = StateObject(wrappedValue: GhosttyTerminalStore(runtime: runtime))
    }

    private var selectedWorktree: Worktree? {
        worktrees.first { $0.id == selectedWorktreeID }
    }

    var body: some View {
        NavigationSplitView {
            SidebarView(worktrees: worktrees, selection: $selectedWorktreeID)
        } detail: {
            Group {
                if let selectedWorktree {
                    GhosttyTerminalView(
                        surfaceView: terminalStore.surfaceView(
                            for: selectedWorktree.id,
                            workingDirectory: selectedWorktree.workingDirectory
                        )
                    )
                    .id(selectedWorktree.id)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    EmptyStateView()
                }
            }
            .navigationTitle(selectedWorktree?.name ?? "Supacode")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button(action: {}) {
                        Image(systemName: "sidebar.left")
                    }
                    Button(action: {}) {
                        Image(systemName: "square.and.pencil")
                    }
                    Button(action: {}) {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

private struct SidebarView: View {
    let worktrees: [Worktree]
    @Binding var selection: Worktree.ID?
    @State private var isRepoExpanded = true

    var body: some View {
        List(selection: $selection) {
            DisclosureGroup(isExpanded: $isRepoExpanded) {
                ForEach(worktrees) { worktree in
                    WorktreeRow(name: worktree.name, detail: worktree.detail)
                        .tag(worktree.id)
                }
            } label: {
                RepoHeaderRow(name: "supacode", initials: "S")
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 220)
    }
}

private struct RepoHeaderRow: View {
    let name: String
    let initials: String
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(.secondary.opacity(0.2))
                Text(initials)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 24, height: 24)
            Text(name)
                .font(.headline)
        }
    }
}

private struct WorktreeRow: View {
    let name: String
    let detail: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: "arrow.triangle.branch")
                .font(.caption)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct EmptyStateView: View {
    var body: some View {
        VStack {
            Image(systemName: "tray")
                .font(.title2)
            Text("Open a project or worktree")
                .font(.headline)
            Text("Double-click an item in the sidebar, or press Cmd+O.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Open...") {}
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
        .multilineTextAlignment(.center)
    }
}
