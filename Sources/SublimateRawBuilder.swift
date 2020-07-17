import class Vapor.Request
import struct Vapor.Abort
import SQLKit

public class SublimateRawBuilder {
    init(builder: SQLRawBuilder) {
        self.builder = builder
    }

    let builder: SQLRawBuilder

    public func first<T: Decodable>(decoding: T.Type) throws -> T? {
        try builder.first(decoding: decoding).wait()
    }

    public func all<T: Decodable>(decoding: T.Type) throws -> [T] {
        try builder.all(decoding: T.self).wait()
    }

    public func run() throws {
        try builder.run().wait()
    }
}

public extension CO₂DB {
    func raw(sql: SQLQueryString) throws -> SublimateRawBuilder {
        guard let db = db as? SQLDatabase else {
            throw Abort(.internalServerError, reason: "Cannot do raw SQL queries on non-SQLDatabase")
        }
        return SublimateRawBuilder(builder: db.raw(sql))
    }
}
