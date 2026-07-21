import CoreGraphics
import Foundation
import ImageIO
@testable import RawParserKit
import Testing
import UniformTypeIdentifiers

struct NumericExifMetadataTests {
    @Test
    func `metadata retains numeric exposure fields`() async throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("rawparserkit-numeric-exif-\(UUID().uuidString)")
            .appendingPathExtension("jpg")
        defer { try? FileManager.default.removeItem(at: url) }

        try writeJPEG(
            to: url,
            exif: [
                kCGImagePropertyExifExposureTime: 0.001,
                kCGImagePropertyExifFNumber: 5.6,
                kCGImagePropertyExifFocalLength: 400.0,
                kCGImagePropertyExifISOSpeedRatings: [800],
                kCGImagePropertyExifExposureBiasValue: -0.333_333,
            ],
        )

        let metadata = try #require(await RawImageLoader.shared.metadata(for: url))

        #expect(metadata.exposureTimeSeconds == 0.001)
        #expect(metadata.apertureValue == 5.6)
        #expect(metadata.focalLengthMM == 400.0)
        #expect(metadata.isoValue == 800)
        #expect(abs(try #require(metadata.exposureCompensationEV) + 0.333_333) < 0.000_001)
    }

    private func writeJPEG(to url: URL, exif: [CFString: Any]) throws {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        let context = try #require(CGContext(
            data: nil,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo,
        ))
        let image = try #require(context.makeImage())
        let destination = try #require(CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.jpeg.identifier as CFString,
            1,
            nil,
        ))
        let properties = [kCGImagePropertyExifDictionary: exif] as CFDictionary
        CGImageDestinationAddImage(destination, image, properties)
        #expect(CGImageDestinationFinalize(destination))
    }
}
