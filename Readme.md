# RawParserKit

RawParserKit is a Swift package for RAW-file parser and preview extraction logic used by RawCull. It keeps camera-vendor binary knowledge in one focused module: MakerNote focus-location parsing, embedded JPEG location discovery, thumbnail extraction, full-preview JPEG extraction, and cancellation-safe ImageIO work.

The package is intentionally independent of RawCull view models, SwiftUI views, persistence, and cache layers. It is suitable for unit testing with synthetic RAW-like TIFF data and for reuse from a macOS app target.

## Supported Formats

- Sony `.arw`
- Nikon `.nef`

## Requirements

- Swift 6
- macOS 26 or newer
- Apple platforms with Foundation, CoreGraphics, ImageIO, CoreImage, and OSLog

## What The Package Provides

- `RawFormat`: a vendor contract for thumbnail extraction, embedded JPEG extraction, focus-location parsing, compression labels, and size-class thresholds.
- `RawFormatRegistry`: extension-based dispatch from a file URL to a registered raw format.
- `SonyMakerNoteParser` and `NikonMakerNoteParser`: TIFF/MakerNote parsers for AF focus locations and embedded JPEG offsets.
- `JPGSonyARWExtractor` and `JPGNikonNEFExtractor`: embedded full-preview JPEG extraction with ImageIO first and parser fallback where needed.
- `SonyThumbnailExtractor` and `NikonThumbnailExtractor`: ImageIO-backed thumbnail extraction with cooperative cancellation.
- `ThumbnailSharpener`: optional `CIRAWFilter` preview sharpening.
- `CancellableImageIOWork`: a small utility for running synchronous ImageIO work off the caller while respecting Swift task cancellation.

## Usage

Resolve a format from a URL:

```swift
import RawParserKit

let url = URL(fileURLWithPath: "/photos/frame.ARW")

if let format = RawFormatRegistry.format(for: url) {
    print(format.rawFileTypeString(compressionCode: 7))
}
```

Read a focus location directly:

```swift
let sonyFocus = SonyMakerNoteParser.focusLocation(from: url)
let nikonFocus = NikonMakerNoteParser.focusLocation(from: url)
```

The focus-location string uses RawCull's existing shape:

```text
"imageWidth imageHeight focusX focusY"
```

Extract a thumbnail through the vendor-neutral format API:

```swift
if let format = RawFormatRegistry.format(for: url) {
    let thumbnail = try await format.extractThumbnail(
        from: url,
        maxDimension: 512,
        qualityCost: 4
    )
}
```

Extract the largest embedded JPEG preview:

```swift
if let format = RawFormatRegistry.format(for: url) {
    let preview = await format.extractFullJPEG(from: url, fullSize: true)
}
```

Develop a full-resolution JPEG from Sony ARW sensor data:

```swift
let jpegData = try await SonyRawFormat.createFullSizeJPEG(
    from: url,
    quality: 1.0
)

await SaveJPGImage().save(jpegData, originalURL: url)
```

This path uses macOS `CIRAWFilter`, not the camera's embedded JPEG. Camera and
compression-mode support therefore follows the RAW decoder installed with macOS.
As of Apple's April 29, 2026 support list, the Sony A7 V (`ILCE-7M5`) is supported
for lossless-compressed RAW only, while the A7R VI (`ILCE-7RM6`) is not listed.
Unsupported files throw `SonyJPEGCreationError.unsupportedOrInvalidRAW`.

Use parser diagnostics when building UI or logs around parse failures:

```swift
let diagnostics = SonyMakerNoteParser.focusLocationDiagnostics(from: url)

if let focus = diagnostics.value {
    print("Focus:", focus)
} else {
    print("Failure:", diagnostics.failure ?? "unknown")
    print(diagnostics.trace.joined(separator: "\n"))
}
```

Read embedded JPEG data from parser-discovered offsets:

```swift
if let locations = SonyMakerNoteParser.embeddedJPEGLocations(from: url),
   let location = locations.preview ?? locations.fullJPEG,
   let data = SonyMakerNoteParser.readEmbeddedJPEGData(at: location, from: url) {
    print("JPEG bytes:", data.count)
}
```

## Concurrency Notes

The public APIs are non-UI and do not depend on SwiftUI, `@Observable`, RawCull view models, or app state. ImageIO thumbnail and JPEG work is wrapped by `CancellableImageIOWork`, which schedules synchronous ImageIO operations on a global queue and resumes the async caller when the work completes or cancellation is observed.

The parser code itself is pure Foundation-based binary reading. It reads either a fast-path prefix window or a full-file fallback, then walks TIFF IFD structures and vendor MakerNote data.

## Development

Build the package:

```bash
swift build
```

Run tests:

```bash
swift test
```

Run tests with code coverage:

```bash
swift test --enable-code-coverage
```

## Test Strategy

The test suite uses Swift Testing and synthetic binary data. It does not require real ARW or NEF files. The tests cover:

- Sony focus-location MakerNote variants
- Nikon focus-location MakerNote variants
- Embedded JPEG offset discovery and JPEG byte reading
- Thumbnail and JPEG extraction cancellation behavior
- Raw format registry extension matching

## Adding A Vendor

Add a new `RawFormat` conformer for the vendor, implement its parser/extractor entrypoints, and register the conformer in `RawFormatRegistry.all`. Prefer synthetic binary fixtures for parser tests so the package remains fast and deterministic.
