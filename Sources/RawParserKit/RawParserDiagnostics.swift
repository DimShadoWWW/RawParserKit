import Foundation

public nonisolated struct RawParserDiagnostics<Value: Sendable> {
    public let value: Value?
    public let trace: [String]
    public let failure: String?

    public init(value: Value?, trace: [String], failure: String?) {
        self.value = value
        self.trace = trace
        self.failure = failure
    }
}
