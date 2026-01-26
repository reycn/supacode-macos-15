nonisolated struct SettingsFile: Codable, Equatable {
  var global: GlobalSettings
  var repositories: [String: RepositorySettings]

  static let `default` = SettingsFile(
    global: .default,
    repositories: [:]
  )
}
