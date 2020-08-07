import Sublimate
import XCTest
import Vapor
import NIO

class NIOTests: CO₂TestCase {
    func testCollectionFlatten() throws {
        app.routes.get("foo", use: sublimate { rq -> [String] in
            let f1 = rq.eventLoop.makeSucceededFuture("1")
            let f2 = rq.eventLoop.makeSucceededFuture("2")
            return try [f1, f2].flatten(on: rq)
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            let rsp = try $0.content.decode([String].self)
            XCTAssertEqual(rsp, ["1", "2"])
            XCTAssertEqual($0.status, .ok)
        }
    }

    func testCollectionFlattenVoid() throws {
        app.routes.get("foo", use: sublimate { rq in
            let f1 = rq.eventLoop.makeSucceededFuture(())
            let f2 = rq.eventLoop.makeSucceededFuture(())
            return try [f1, f2].flatten(on: rq)
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            XCTAssertEqual($0.status, .ok)
        }
    }

    func testFail() throws {
        app.routes.get("foo", use: sublimate { rq in
            throw Abort(.notFound)
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            XCTAssertEqual($0.status, .notFound)
        }
    }
}
