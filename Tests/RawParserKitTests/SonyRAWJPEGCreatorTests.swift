import CoreImage
import Foundation
import ImageIO
@testable import RawParserKit
import Testing

struct SonyRAWJPEGCreatorTests {
    @Test(arguments: [-0.1, 1.1, .infinity, .nan])
    func `invalid JPEG quality throws a typed error`(quality: Double) async {
        await #expect(throws: SonyJPEGCreationError.self) {
            _ = try await SonyRawFormat.createFullSizeJPEG(
                from: URL(fileURLWithPath: "/tmp/quality-validation.arw"),
                quality: quality
            )
        }
    }

    @Test
    func `missing ARW throws unsupported or invalid RAW`() async {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("missing-\(UUID().uuidString).arw")

        await #expect(throws: SonyJPEGCreationError.unsupportedOrInvalidRAW) {
            _ = try await SonyRawFormat.createFullSizeJPEG(from: url)
        }
    }

    @Test
    func `malformed ARW throws unsupported or invalid RAW`() async throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("malformed-\(UUID().uuidString).arw")
        try Data("not raw image data".utf8).write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }

        await #expect(throws: SonyJPEGCreationError.unsupportedOrInvalidRAW) {
            _ = try await SonyRawFormat.createFullSizeJPEG(from: url)
        }
    }

    @Test
    func `cancelled RAW development throws cancellation`() async {
        await withTaskGroup(of: Void.self) { group in
            group.cancelAll()
            group.addTask {
                await #expect(throws: CancellationError.self) {
                    _ = try await SonyRawFormat.createFullSizeJPEG(
                        from: URL(fileURLWithPath: "/tmp/cancelled.arw")
                    )
                }
            }
        }
    }

    @Test
    func `encoder creates an sRGB JPEG with original dimensions`() throws {
        let width = 96
        let height = 64
        let image = CIImage(
            color: CIColor(red: 0.2, green: 0.6, blue: 0.9)
        ).cropped(to: CGRect(x: 0, y: 0, width: width, height: height))

        let data = try SonyRAWJPEGCreator.encodeJPEG(from: image, quality: 1.0)
        let source = try #require(CGImageSourceCreateWithData(data as CFData, nil))
        let properties = try #require(
            CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
        )
        let colorModel = properties[kCGImagePropertyColorModel] as? String

        #expect(properties[kCGImagePropertyPixelWidth] as? Int == width)
        #expect(properties[kCGImagePropertyPixelHeight] as? Int == height)
        #expect(colorModel == kCGImagePropertyColorModelRGB as String)
    }

    @Test
    func `encoder reports JPEG representation failure`() {
        let infiniteImage = CIImage(color: .white)

        #expect(throws: SonyJPEGCreationError.encodingFailed) {
            _ = try SonyRAWJPEGCreator.encodeJPEG(from: infiniteImage, quality: 1.0)
        }
    }
}
