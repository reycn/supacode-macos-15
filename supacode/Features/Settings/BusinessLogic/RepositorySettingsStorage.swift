import Foundation

nonisolated struct RepositorySettingsStorage {
  func load(for rootURL: URL) -> RepositorySettings {
    let repositoryID = repositoryID(for: rootURL)
    var fileSettings = SettingsStorage().load()
    if let settings = fileSettings.repositories[repositoryID] {
      return settings
    }
    let defaults = RepositorySettings.default
    fileSettings.repositories[repositoryID] = defaults
    SettingsStorage().save(fileSettings)
    return defaults
  }

  func save(_ settings: RepositorySettings, for rootURL: URL) {
    let repositoryID = repositoryID(for: rootURL)
    var fileSettings = SettingsStorage().load()
    fileSettings.repositories[repositoryID] = settings
    SettingsStorage().save(fileSettings)
  }

  private func repositoryID(for rootURL: URL) -> String {
    rootURL.standardizedFileURL.path(percentEncoded: false)
  }
}
