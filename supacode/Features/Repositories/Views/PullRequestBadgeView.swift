import SwiftUI

enum PullRequestBadgeStyle {
  static let mergedColor = Color(red: 137.0 / 255.0, green: 87.0 / 255.0, blue: 229.0 / 255.0)
  static let openColor = Color(red: 35.0 / 255.0, green: 134.0 / 255.0, blue: 54.0 / 255.0)

  static func style(state: String?, number: Int?) -> (text: String, color: Color)? {
    guard let state = state?.uppercased() else {
      return nil
    }
    switch state {
    case "MERGED":
      return (text: number.map { "#\($0)" } ?? "MERGED", color: mergedColor)
    case "OPEN":
      return (text: number.map { "#\($0)" } ?? "OPEN", color: openColor)
    default:
      return nil
    }
  }

  static func helpText(state: String?, url: URL?) -> String {
    let state = state?.uppercased()
    switch state {
    case "MERGED":
      return url == nil ? "Pull request merged" : "Open merged pull request on GitHub"
    case "OPEN":
      return url == nil ? "Pull request open" : "Open pull request on GitHub"
    default:
      return url == nil ? "Pull request" : "Open pull request on GitHub"
    }
  }
}

struct PullRequestBadgeView: View {
  let text: String
  let color: Color

  var body: some View {
    Text(text)
      .font(.caption2)
      .monospaced()
      .foregroundStyle(color)
      .padding(.horizontal, 6)
      .padding(.vertical, 2)
      .overlay {
        RoundedRectangle(cornerRadius: 4)
          .stroke(color, lineWidth: 1)
      }
      .accessibilityLabel(text)
  }
}
