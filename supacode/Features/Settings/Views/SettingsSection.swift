import Foundation

enum SettingsSection: Hashable {
  case agents
  case chat
  case appearance
  case updates
  case repository(Repository.ID)
}
