import Foundation

public struct BrowserFocusPoint: Equatable {
    public let normalizedX: Double
    public let normalizedY: Double

    public nonisolated init(normalizedX: Double, normalizedY: Double) {
        self.normalizedX = normalizedX
        self.normalizedY = normalizedY
    }
}
