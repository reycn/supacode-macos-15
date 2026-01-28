import Foundation
import Testing

@testable import supacode

struct RepositorySettingsStorageTests {
  @Test func loadCreatesDefaultAndPersists() async throws {
    let root = try makeTempDirectory()
    defer { try? FileManager.default.removeItem(at: root) }
    let settingsURL = root.appending(path: "settings.json")

    let storage = SettingsStorage(settingsURL: settingsURL)
    let repositoryStorage = RepositorySettingsStorage(storage: storage)
    let rootURL = URL(fileURLWithPath: "/tmp/repo")

    let settings = await repositoryStorage.load(for: rootURL)

    #expect(settings == RepositorySettings.default)

    let saved = await storage.load()
    #expect(saved.repositories[rootURL.path(percentEncoded: false)] == RepositorySettings.default)
  }

  @Test func saveOverwritesExistingSettings() async throws {
    let root = try makeTempDirectory()
    defer { try? FileManager.default.removeItem(at: root) }
    let settingsURL = root.appending(path: "settings.json")
    let storage = SettingsStorage(settingsURL: settingsURL)
    let repositoryStorage = RepositorySettingsStorage(storage: storage)
    let rootURL = URL(fileURLWithPath: "/tmp/repo")

    var settings = RepositorySettings.default
    settings.runScript = "echo updated"
    await repositoryStorage.save(settings, for: rootURL)

    let reloaded = await storage.load()
    #expect(reloaded.repositories[rootURL.path(percentEncoded: false)] == settings)
  }

  private func makeTempDirectory() throws -> URL {
    let url = FileManager.default.temporaryDirectory
      .appending(path: UUID().uuidString, directoryHint: .isDirectory)
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    return url
  }
}
