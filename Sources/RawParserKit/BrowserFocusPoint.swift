import Foundation

public struct RawFocusPoint: Equatable, Sendable {
    public nonisolated let normalizedX: Double
    public nonisolated let normalizedY: Double

    public nonisolated init(normalizedX: Double, normalizedY: Double) {
        self.normalizedX = normalizedX
        self.normalizedY = normalizedY
    }

    public nonisolated init?(focusLocation: String) {
        let values = focusLocation
            .split(whereSeparator: \.isWhitespace)
            .compactMap { Double($0) }

        guard values.count == 4,
              values[0] > 0,
              values[1] > 0
        else { return nil }

        let normalizedX = values[2] / values[0]
        let normalizedY = values[3] / values[1]
        guard (0 ... 1).contains(normalizedX), (0 ... 1).contains(normalizedY) else { return nil }

        self.init(normalizedX: normalizedX, normalizedY: normalizedY)
    }
}

@available(*, deprecated, renamed: "RawFocusPoint")
public typealias BrowserFocusPoint = RawFocusPoint
