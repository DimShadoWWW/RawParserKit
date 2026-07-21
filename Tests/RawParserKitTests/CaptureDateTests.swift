import Foundation
@testable import RawParserKit
import Testing

struct CaptureDateTests {
    @Test
    func `capture date preserves subsecond precision and offset`() throws {
        let date = try #require(RawImageLoader.captureDate(
            from: "2026:07:21 14:03:04",
            subsecond: "125",
            offset: "+02:00",
        ))
        let expected = try #require(gmtCalendar.date(from: DateComponents(
            year: 2026,
            month: 7,
            day: 21,
            hour: 12,
            minute: 3,
            second: 4,
        )))

        #expect(abs(date.timeIntervalSince(expected) - 0.125) < 0.000_001)
    }

    @Test(arguments: [
        (subsecond: "9", expected: 0.9),
        (subsecond: "09", expected: 0.09),
        (subsecond: "000001", expected: 0.000_001),
    ])
    func `capture date accepts variable subsecond precision`(
        subsecond: String,
        expected: TimeInterval,
    ) throws {
        let gmt = try #require(TimeZone(secondsFromGMT: 0))
        let base = try #require(RawImageLoader.captureDate(
            from: "2026:07:21 14:03:04",
            subsecond: nil,
            offset: nil,
            defaultTimeZone: gmt,
        ))
        let precise = try #require(RawImageLoader.captureDate(
            from: "2026:07:21 14:03:04",
            subsecond: subsecond,
            offset: nil,
            defaultTimeZone: gmt,
        ))

        #expect(abs(precise.timeIntervalSince(base) - expected) < 0.000_001)
    }

    @Test
    func `capture date is nil when DateTimeOriginal is missing or invalid`() {
        #expect(RawImageLoader.captureDate(
            from: nil,
            subsecond: "125",
            offset: "+02:00",
        ) == nil)
        #expect(RawImageLoader.captureDate(
            from: "not a date",
            subsecond: "125",
            offset: "+02:00",
        ) == nil)
    }

    @Test(arguments: [
        (value: "+02:00", expected: 7_200),
        (value: "-0530", expected: -19_800),
        (value: "Z", expected: 0),
    ])
    func `capture offset is retained in seconds`(value: String, expected: Int) {
        #expect(RawImageLoader.captureTimeZoneOffsetSeconds(from: value) == expected)
    }

    private var gmtCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }
}
