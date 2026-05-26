import Foundation
@testable import RawParserKit
import Testing

struct RawFormatRegistryTests {
    @Test
    func `format resolves supported extensions case insensitively`() {
        #expect(RawFormatRegistry.format(for: URL(fileURLWithPath: "/tmp/image.arw")) is SonyRawFormat.Type)
        #expect(RawFormatRegistry.format(for: URL(fileURLWithPath: "/tmp/image.ARW")) is SonyRawFormat.Type)
        #expect(RawFormatRegistry.format(for: URL(fileURLWithPath: "/tmp/image.nef")) is NikonRawFormat.Type)
        #expect(RawFormatRegistry.format(for: URL(fileURLWithPath: "/tmp/image.NEF")) is NikonRawFormat.Type)
    }

    @Test
    func `format rejects unsupported extensions`() {
        #expect(RawFormatRegistry.format(for: URL(fileURLWithPath: "/tmp/image.jpg")) == nil)
        #expect(RawFormatRegistry.format(for: URL(fileURLWithPath: "/tmp/image")) == nil)
    }

    @Test
    func `allExtensions is union of registered raw formats`() {
        #expect(RawFormatRegistry.allExtensions == ["arw", "nef"])
    }
}
