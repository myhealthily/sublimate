import enum NIOHTTP1.HTTPResponseStatus

// We extend `AbortError` in the Sublimate module since we cannot depend on Vapor here or SublimateFluentKit
public struct SublimateAbort: Error {
    public let status: HTTPResponseStatus
    public let reason: String
    public let file: StaticString
    public let line: UInt

    public init(_ status: HTTPResponseStatus, reason: String, file: StaticString = #file, line: UInt = #line) {
        self.status = status
        self.reason = reason
        self.file = file
        self.line = line
    }
}
