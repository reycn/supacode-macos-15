import ComposableArchitecture
import Foundation

struct SettingsClient {
  var load: @Sendable () -> GlobalSettings
  var save: @Sendable (GlobalSettings) -> Void
}

extension SettingsClient: DependencyKey {
  static let liveValue = SettingsClient(
    load: { SettingsStorage().load().global },
    save: { settings in
      var fileSettings = SettingsStorage().load()
      fileSettings.global = settings
      SettingsStorage().save(fileSettings)
    }
  )
  static let testValue = SettingsClient(
    load: { .default },
    save: { _ in }
  )
}

extension DependencyValues {
  var settingsClient: SettingsClient {
    get { self[SettingsClient.self] }
    set { self[SettingsClient.self] = newValue }
  }
}
