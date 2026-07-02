import Foundation

public struct BrowserExifInfo: Equatable {
    public let camera: String?
    public let lens: String?
    public let exposure: String?
    public let aperture: String?
    public let focalLength: String?
    public let iso: String?
    public let capturedAt: String?
    public let dimensions: String?
    public let focusPoint: BrowserFocusPoint?

    public nonisolated init(
        camera: String?,
        lens: String?,
        exposure: String?,
        aperture: String?,
        focalLength: String?,
        iso: String?,
        capturedAt: String?,
        dimensions: String?,
        focusPoint: BrowserFocusPoint?
    ) {
        self.camera = camera
        self.lens = lens
        self.exposure = exposure
        self.aperture = aperture
        self.focalLength = focalLength
        self.iso = iso
        self.capturedAt = capturedAt
        self.dimensions = dimensions
        self.focusPoint = focusPoint
    }

    public nonisolated var rows: [(String, String)] {
        [
            ("Camera", camera),
            ("Lens", lens),
            ("Exposure", exposure),
            ("Aperture", aperture),
            ("Focal Length", focalLength),
            ("ISO", iso),
            ("Captured", capturedAt),
            ("Dimensions", dimensions)
        ].compactMap { label, value in
            guard let value, !value.isEmpty else { return nil }
            return (label, value)
        }
    }

    public nonisolated var isEmpty: Bool {
        rows.isEmpty
    }
}
