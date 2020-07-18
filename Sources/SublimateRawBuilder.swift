import class Vapor.Request
import struct Vapor.Abort
import SQLKit

/// Sublimate utility object wrapping a SQLKit `SQLRawBuilder` object.
public final class SublimateRawBuilder {
    fileprivate init(kernel: SQLRawBuilder) {
        self.kernel = kernel
    }

    // `public` so we can be inlinable
    public let kernel: SQLRawBuilder

    @inlinable
    public func first<T: Decodable>(decoding: T.Type) throws -> T? {
        try kernel.first(decoding: decoding).wait()
    }

    /// Collects the first raw output and returns it.
    @inlinable
    public func first() throws -> SQLRow? {
        try kernel.first().wait()
    }

    @inlinable
    public func all<T: Decodable>(decoding: T.Type) throws -> [T] {
        try kernel.all(decoding: T.self).wait()
    }

    /// Collects all raw output into an array and returns it.
    @inlinable
    public func all() throws -> [SQLRow] {
        try kernel.all().wait()
    }

    @inlinable
    public func run() throws {
        try kernel.run().wait()
    }
}

public extension CO₂DB {
    func raw(sql: SQLQueryString, file: String = #file, line: UInt = #line) throws -> SublimateRawBuilder {
        guard let db = db as? SQLDatabase else {
            throw Abort(.internalServerError, reason: "Cannot do raw SQL queries on non-SQLDatabase", file: file, line: line)
        }
        return SublimateRawBuilder(kernel: db.raw(sql))
    }
}
