import Foundation

public struct RawImageMetadata: Equatable, Sendable {
    public nonisolated let camera: String?
    public nonisolated let lens: String?
    public nonisolated let exposure: String?
    public nonisolated let aperture: String?
    public nonisolated let apertureValue: Double?
    public nonisolated let focalLength: String?
    public nonisolated let iso: String?
    public nonisolated let isoValue: Int?
    public nonisolated let capturedAt: String?
    public nonisolated let captureDate: Date?
    public nonisolated let dimensions: String?
    public nonisolated let focusPoint: RawFocusPoint?
    public nonisolated let rawFileType: String?
    public nonisolated let rawSizeClass: String?
    public nonisolated let pixelWidth: Int?
    public nonisolated let pixelHeight: Int?

    public nonisolated init(
        camera: String?,
        lens: String?,
        exposure: String?,
        aperture: String?,
        apertureValue: Double? = nil,
        focalLength: String?,
        iso: String?,
        isoValue: Int? = nil,
        capturedAt: String?,
        captureDate: Date? = nil,
        dimensions: String?,
        focusPoint: RawFocusPoint?,
        rawFileType: String? = nil,
        rawSizeClass: String? = nil,
        pixelWidth: Int? = nil,
        pixelHeight: Int? = nil
    ) {
        self.camera = camera
        self.lens = lens
        self.exposure = exposure
        self.aperture = aperture
        self.apertureValue = apertureValue
        self.focalLength = focalLength
        self.iso = iso
        self.isoValue = isoValue
        self.capturedAt = capturedAt
        self.captureDate = captureDate
        self.dimensions = dimensions
        self.focusPoint = focusPoint
        self.rawFileType = rawFileType
        self.rawSizeClass = rawSizeClass
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
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
            ("Dimensions", dimensions),
            ("RAW Type", rawFileType),
            ("RAW Size", rawSizeClass)
        ].compactMap { label, value in
            guard let value, !value.isEmpty else { return nil }
            return (label, value)
        }
    }

    public nonisolated var isEmpty: Bool {
        rows.isEmpty
    }
}

@available(*, deprecated, renamed: "RawImageMetadata")
public typealias BrowserExifInfo = RawImageMetadata
