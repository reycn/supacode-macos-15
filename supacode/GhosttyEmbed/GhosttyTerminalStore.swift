import Combine
import Foundation

final class GhosttyTerminalStore: ObservableObject {
    private let runtime: GhosttyRuntime
    private var surfaceViews: [UUID: GhosttySurfaceView] = [:]

    init(runtime: GhosttyRuntime) {
        self.runtime = runtime
    }

    func surfaceView(for id: UUID, workingDirectory: String?) -> GhosttySurfaceView {
        if let existing = surfaceViews[id] {
            return existing
        }
        let view = GhosttySurfaceView(runtime: runtime, workingDirectory: workingDirectory)
        surfaceViews[id] = view
        return view
    }
}
