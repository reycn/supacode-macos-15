import ComposableArchitecture
import Foundation
import Testing

@testable import supacode

struct RepositoryPersistenceClientTests {
  @Test func savesAndLoadsRootsAndPins() async throws {
    let root = try makeTempDirectory()
    defer { try? FileManager.default.removeItem(at: root) }
    let settingsURL = root.appending(path: "settings.json")
    let storage = SettingsStorage(settingsURL: settingsURL)

    var settings = await storage.load()
    settings.global.appearanceMode = .dark
    await storage.save(settings)

    let client = RepositoryPersistenceClient(
      loadRoots: { await storage.load().repositoryRoots },
      saveRoots: { roots in
        await storage.update { fileSettings in
          fileSettings.repositoryRoots = roots
        }
      },
      loadPinnedWorktreeIDs: { await storage.load().pinnedWorktreeIDs },
      savePinnedWorktreeIDs: { ids in
        await storage.update { fileSettings in
          fileSettings.pinnedWorktreeIDs = ids
        }
      }
    )

    await client.saveRoots(["/tmp/repo-a", "/tmp/repo-b"])
    await client.savePinnedWorktreeIDs(["/tmp/repo-a/wt-1"])

    let loadedRoots = await client.loadRoots()
    let loadedPinned = await client.loadPinnedWorktreeIDs()
    let finalSettings = await storage.load()

    #expect(loadedRoots == ["/tmp/repo-a", "/tmp/repo-b"])
    #expect(loadedPinned == ["/tmp/repo-a/wt-1"])
    #expect(finalSettings.global.appearanceMode == .dark)
  }

  private func makeTempDirectory() throws -> URL {
    let url = FileManager.default.temporaryDirectory
      .appending(path: UUID().uuidString, directoryHint: .isDirectory)
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    return url
  }
}
