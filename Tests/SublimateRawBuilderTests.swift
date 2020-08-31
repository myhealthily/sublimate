@testable import Sublimate
import FluentKit
import XCTFluent
import XCTest
import Vapor

class SublimateRawBuilderTests: CO₂TestCase {
    func testRun() throws {
        app.routes.get("foo", use: sublimate { rq in
            try rq.raw(sql: "CREATE TABLE foo (id INTEGER PRIMARY KEY)").run()
            try rq.run(sql: "INSERT INTO foo (id) VALUES (0)")
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            XCTAssertEqual($0.status, .ok)
        }
    }

    func testFirst() throws {
        app.routes.get("foo", use: sublimate { rq in
            try rq.raw(sql: "CREATE TABLE foo (id INTEGER PRIMARY KEY)").run()
            try rq.raw(sql: "INSERT INTO foo (id) VALUES (0)").run()
            XCTAssertNotNil(try rq.raw(sql: "SELECT * FROM foo").first())
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            XCTAssertEqual($0.status, .ok)
        }
    }

    func testFirstOrAbort() throws {
        app.routes.get("foo", use: sublimate { rq in
            try rq.raw(sql: "CREATE TABLE foo (id INTEGER PRIMARY KEY)").run()
            XCTAssertThrowsError(try rq.raw(sql: "SELECT * FROM foo").first(or: .abort))

            try rq.raw(sql: "INSERT INTO foo (id) VALUES (0)").run()
            XCTAssertNotNil(try rq.raw(sql: "SELECT * FROM foo").first(or: .abort))
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            XCTAssertEqual($0.status, .ok)
        }
    }

    func testFirstDecoding() throws {
        app.routes.get("foo", use: sublimate { rq in
            try rq.raw(sql: "CREATE TABLE foo (id INTEGER PRIMARY KEY)").run()
            try rq.raw(sql: "INSERT INTO foo (id) VALUES (0)").run()
            XCTAssertNotNil(try rq.raw(sql: "SELECT * FROM foo").first(decoding: Row.self))
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            XCTAssertEqual($0.status, .ok)
        }
    }

    func testFirstDecodingOrAbort() throws {
        app.routes.get("foo", use: sublimate { rq in
            try rq.raw(sql: "CREATE TABLE foo (id INTEGER PRIMARY KEY)").run()
            XCTAssertThrowsError(try rq.raw(sql: "SELECT * FROM foo").first(or: .abort, decoding: Row.self))

            try rq.raw(sql: "INSERT INTO foo (id) VALUES (0)").run()
            XCTAssertNotNil(try rq.raw(sql: "SELECT * FROM foo").first(or: .abort, decoding: Row.self))
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            XCTAssertEqual($0.status, .ok)
        }
    }

    func testFirstDecodingModel() throws {
        app.routes.get("foo", use: sublimate { rq in
            try rq.raw(sql: "CREATE TABLE foo (id UUID PRIMARY KEY, bar INTEGER NOT NULL)").run()
            try rq.raw(sql: "INSERT INTO foo (id, bar) VALUES (\(bind: UUID().uuidString), \(bind: 0))").run()
            XCTAssertNotNil(try rq.raw(sql: "SELECT * FROM foo").first(or: .abort, decoding: Model.self))
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            XCTAssertEqual($0.status, .ok)
        }
    }

    func testFirstDecodingModelOrAbort() throws {
        app.routes.get("foo", use: sublimate { rq in
            try rq.raw(sql: "CREATE TABLE foo (id UUID PRIMARY KEY, bar INTEGER NOT NULL)").run()
            XCTAssertThrowsError(try rq.raw(sql: "SELECT * FROM foo").first(or: .abort, decoding: Model.self))

            try rq.raw(sql: "INSERT INTO foo (id, bar) VALUES (\(bind: UUID().uuidString), \(bind: 0))").run()
            XCTAssertNotNil(try rq.raw(sql: "SELECT * FROM foo").first(decoding: Model.self))
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            XCTAssertEqual($0.status, .ok)
        }
    }

    func testAll() throws {
        app.routes.get("foo", use: sublimate { rq in
            try rq.raw(sql: "CREATE TABLE foo (id INTEGER PRIMARY KEY)").run()
            try rq.raw(sql: "INSERT INTO foo (id) VALUES (0)").run()
            XCTAssertEqual(try rq.raw(sql: "SELECT * FROM foo").all().count, 1)
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            XCTAssertEqual($0.status, .ok)
        }
    }

    func testAllDecoding() throws {
        app.routes.get("foo", use: sublimate { rq in
            try rq.raw(sql: "CREATE TABLE foo (id INTEGER PRIMARY KEY)").run()
            try rq.raw(sql: "INSERT INTO foo (id) VALUES (0)").run()
            XCTAssertEqual(try rq.raw(sql: "SELECT * FROM foo").all(decoding: Row.self).count, 1)
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            XCTAssertEqual($0.status, .ok)
        }
    }

    func testAllDecodingModel() throws {
        app.routes.get("foo", use: sublimate { rq in
            try rq.raw(sql: "CREATE TABLE foo (id UUID PRIMARY KEY, bar INTEGER NOT NULL)").run()
            try rq.raw(sql: "INSERT INTO foo (id, bar) VALUES (\(bind: UUID().uuidString), \(bind: 0))").run()
            XCTAssertEqual(try rq.raw(sql: "SELECT * FROM foo").all(decoding: Model.self).count, 1)
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            XCTAssertEqual($0.status, .ok)
        }
    }


    func testThrows() throws {
        let db = ArrayTestDatabase()
        try db.sublimate { db in
            XCTAssertThrowsError(try db.run(sql: ""))
        }.wait()
    }
}

private struct Row: Decodable {
    let id: Int
}

private extension TestDatabase {
    func sublimate<T>(use closure: @escaping (CO₂DB) throws -> T) -> EventLoopFuture<T> {
        DispatchQueue.global().async(on: db.eventLoop) {
            try closure(CO₂DB(db: self.db))
        }
    }
}

private final class Model: FluentKit.Model {
    public init() {}
    @ID(key: .id) var id: UUID?
    @Field(key: "bar") var baz: Int
    static let schema = "foo"
}
