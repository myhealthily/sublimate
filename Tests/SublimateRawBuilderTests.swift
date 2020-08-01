import Sublimate
import XCTFluent
import XCTest
import Vapor

class SublimateRawBuilderTests: CO₂TestCase {
    func testRun() throws {
        app.routes.get("foo", use: sublimate { rq -> Void in
            try rq.raw(sql: "CREATE TABLE foo (id INTEGER PRIMARY KEY)").run()
            try rq.run(sql: "INSERT INTO foo (id) VALUES (0)")
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            XCTAssertEqual($0.status, .ok)
        }
    }

    func testFirst() throws {
        app.routes.get("foo", use: sublimate { rq -> Void in
            try rq.raw(sql: "CREATE TABLE foo (id INTEGER PRIMARY KEY)").run()
            try rq.raw(sql: "INSERT INTO foo (id) VALUES (0)").run()
            _ = try rq.raw(sql: "SELECT * FROM foo").first()
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            XCTAssertEqual($0.status, .ok)
        }
    }

    func testFirstDecoding() throws {
        app.routes.get("foo", use: sublimate { rq -> Void in
            try rq.raw(sql: "CREATE TABLE foo (id INTEGER PRIMARY KEY)").run()
            try rq.raw(sql: "INSERT INTO foo (id) VALUES (0)").run()
            _ = try rq.raw(sql: "SELECT * FROM foo").first(decoding: Row.self)
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            XCTAssertEqual($0.status, .ok)
        }
    }

    func testAll() throws {
        app.routes.get("foo", use: sublimate { rq -> Void in
            try rq.raw(sql: "CREATE TABLE foo (id INTEGER PRIMARY KEY)").run()
            try rq.raw(sql: "INSERT INTO foo (id) VALUES (0)").run()
            _ = try rq.raw(sql: "SELECT * FROM foo").all()
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            XCTAssertEqual($0.status, .ok)
        }
    }

    func testAllDecoding() throws {
        app.routes.get("foo", use: sublimate { rq -> Void in
            try rq.raw(sql: "CREATE TABLE foo (id INTEGER PRIMARY KEY)").run()
            try rq.raw(sql: "INSERT INTO foo (id) VALUES (0)").run()
            _ = try rq.raw(sql: "SELECT * FROM foo").all(decoding: Row.self)
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
