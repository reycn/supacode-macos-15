import ComposableArchitecture

struct EditorActionResolver {
  var resolve: @MainActor @Sendable () -> OpenWorktreeAction
}

extension EditorActionResolver: DependencyKey {
  static let liveValue = EditorActionResolver {
    OpenWorktreeAction.editorPriority.first(where: \.isInstalled)
      ?? OpenWorktreeAction.preferredDefault()
  }

  static let testValue = EditorActionResolver { .finder }
}

extension DependencyValues {
  var editorActionResolver: EditorActionResolver {
    get { self[EditorActionResolver.self] }
    set { self[EditorActionResolver.self] = newValue }
  }
}
