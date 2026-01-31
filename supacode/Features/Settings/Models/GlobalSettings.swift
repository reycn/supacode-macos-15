nonisolated struct GlobalSettings: Codable, Equatable, Sendable {
  var appearanceMode: AppearanceMode
  var confirmBeforeQuit: Bool
  var updatesAutomaticallyCheckForUpdates: Bool
  var updatesAutomaticallyDownloadUpdates: Bool
  var inAppNotificationsEnabled: Bool
  var notificationSoundEnabled: Bool
  var deleteBranchOnArchive: Bool

  static let `default` = GlobalSettings(
    appearanceMode: .dark,
    confirmBeforeQuit: true,
    updatesAutomaticallyCheckForUpdates: true,
    updatesAutomaticallyDownloadUpdates: false,
    inAppNotificationsEnabled: true,
    notificationSoundEnabled: true,
    deleteBranchOnArchive: true
  )

  init(
    appearanceMode: AppearanceMode,
    confirmBeforeQuit: Bool,
    updatesAutomaticallyCheckForUpdates: Bool,
    updatesAutomaticallyDownloadUpdates: Bool,
    inAppNotificationsEnabled: Bool,
    notificationSoundEnabled: Bool,
    deleteBranchOnArchive: Bool
  ) {
    self.appearanceMode = appearanceMode
    self.confirmBeforeQuit = confirmBeforeQuit
    self.updatesAutomaticallyCheckForUpdates = updatesAutomaticallyCheckForUpdates
    self.updatesAutomaticallyDownloadUpdates = updatesAutomaticallyDownloadUpdates
    self.inAppNotificationsEnabled = inAppNotificationsEnabled
    self.notificationSoundEnabled = notificationSoundEnabled
    self.deleteBranchOnArchive = deleteBranchOnArchive
  }

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    appearanceMode = try container.decode(AppearanceMode.self, forKey: .appearanceMode)
    confirmBeforeQuit =
      try container.decodeIfPresent(Bool.self, forKey: .confirmBeforeQuit)
      ?? Self.default.confirmBeforeQuit
    updatesAutomaticallyCheckForUpdates = try container.decode(Bool.self, forKey: .updatesAutomaticallyCheckForUpdates)
    updatesAutomaticallyDownloadUpdates = try container.decode(Bool.self, forKey: .updatesAutomaticallyDownloadUpdates)
    inAppNotificationsEnabled =
      try container.decodeIfPresent(Bool.self, forKey: .inAppNotificationsEnabled)
      ?? Self.default.inAppNotificationsEnabled
    notificationSoundEnabled =
      try container.decodeIfPresent(Bool.self, forKey: .notificationSoundEnabled)
      ?? Self.default.notificationSoundEnabled
    deleteBranchOnArchive =
      try container.decodeIfPresent(Bool.self, forKey: .deleteBranchOnArchive)
      ?? Self.default.deleteBranchOnArchive
  }
}
