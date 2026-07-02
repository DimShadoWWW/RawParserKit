import Foundation
@testable import RawParserKit
import Testing

struct PublicAPICleanupTests {
    @Test
    func `format display names describe registered raw formats`() {
        #expect(SonyRawFormat.displayName == "Sony ARW")
        #expect(NikonRawFormat.displayName == "Nikon NEF")
    }

    @Test
    func `raw size class helper uses format thresholds`() {
        #expect(SonyRawFormat.rawSizeClass(width: 9504, height: 6336, camera: "ILCE-7RM6") == "L")
        #expect(SonyRawFormat.rawSizeClass(width: 6240, height: 4160, camera: "ILCE-7RM6") == "M")
        #expect(SonyRawFormat.rawSizeClass(width: 4752, height: 3168, camera: "ILCE-7RM6") == "S")
    }

    @Test
    func `raw focus point parses normalized focus location strings`() throws {
        let point = try #require(RawFocusPoint(focusLocation: "6000 4000 3000 1000"))

        #expect(point.normalizedX == 0.5)
        #expect(point.normalizedY == 0.25)
        #expect(RawFocusPoint(focusLocation: "6000 4000 7000 1000") == nil)
        #expect(RawFocusPoint(focusLocation: "0 4000 1000 1000") == nil)
    }

    @Test
    func `new embedded JPEG extractor names preserve nil behavior for missing files`() async {
        let sonyURL = missingRawURL(extension: "arw")
        let nikonURL = missingRawURL(extension: "nef")

        #expect(await SonyEmbeddedJPEGExtractor.extractEmbeddedJPEG(from: sonyURL) == nil)
        #expect(await NikonEmbeddedJPEGExtractor.extractEmbeddedJPEG(from: nikonURL) == nil)
        #expect(await SonyRawFormat.extractEmbeddedPreview(from: sonyURL, fullSize: false) == nil)
        #expect(await NikonRawFormat.extractEmbeddedPreview(from: nikonURL, fullSize: false) == nil)
    }

    private func missingRawURL(extension pathExtension: String) -> URL {
        URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("rawparserkit-public-api-\(UUID().uuidString)")
            .appendingPathExtension(pathExtension)
    }
}
