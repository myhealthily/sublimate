@testable import Sublimate
import XCTFluent
import XCTVapor
import Fluent
import XCTest
import Vapor

final class CO₂Tests: CO₂TestCase {
    func testHTTPStatus() throws {
        app.routes.get("foo", use: sublimate { rq -> HTTPStatus in
            XCTAssertFalse(rq.db.inTransaction)
            return .ok
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            XCTAssertEqual($0.status, .ok)
        }
    }

    func testHTTPResponse() throws {
        app.routes.get("foo", use: sublimate { rq -> Response in
            XCTAssertFalse(rq.db.inTransaction)
            return Response(status: .ok)
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            XCTAssertEqual($0.status, .ok)
        }
    }

    func testVoid() throws {
        var foo = false

        app.routes.get("foo", use: sublimate { rq -> Void in
            XCTAssertFalse(rq.db.inTransaction)
            foo = true
        })

        try app.testable(method: .inMemory).test(.GET, "foo") { _ in
            XCTAssert(foo)
        }
    }

    func testEncodable() throws {
        app.routes.get("foo", use: sublimate { rq -> Encodable in
            XCTAssertFalse(rq.db.inTransaction)
            return Encodable(foo: true)
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            let rsp = try $0.content.decode(Decodable.self)
            XCTAssertEqual(rsp.foo, true)
        }
    }

    func testTransactionHTTPStatus() throws {
        app.routes.get("foo", use: sublimate(in: .transaction) { rq -> HTTPStatus in
            XCTAssert(rq.db.inTransaction)
            return .ok
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            XCTAssertEqual($0.status, .ok)
        }
    }

    func testTransactionVoid() throws {
        var foo = false

        app.routes.get("foo", use: sublimate(in: .transaction) { rq -> Void in
            XCTAssert(rq.db.inTransaction)
            foo = true
        })

        try app.testable(method: .inMemory).test(.GET, "foo") { _ in
            XCTAssert(foo)
        }
    }

    func testTransactionHTTPResponse() throws {
        var foo = false

        app.routes.get("foo", use: sublimate(in: .transaction) { rq -> Response in
            XCTAssert(rq.db.inTransaction)
            foo = true
            return Response(status: .ok)
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            XCTAssertEqual($0.status, .ok)
            XCTAssert(foo)
        }
    }

    func testTransactionEncodable() throws {
        var foo = false

        app.routes.get("foo", use: sublimate(in: .transaction) { rq -> Encodable in
            XCTAssert(rq.db.inTransaction)
            foo = true
            return Encodable(foo: true)
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            let rsp = try $0.content.decode(Decodable.self)
            XCTAssertEqual(rsp.foo, true)
            XCTAssert(foo)
        }
    }
}

extension CO₂Tests {
    // doesn't work, dunno why
//    func testAuthedHTTPStatus() throws {
//        app.routes.grouped(UserAuthenticator()).get("foo", use: sublimate { (rq, user: Authenticatable) -> HTTPStatus in
//            XCTAssertFalse(rq.db.inTransaction)
//            XCTAssertEqual(user.name, "CO₂")
//            return .ok
//        })
//
//        try app.testable(method: .inMemory).test(.GET, "foo") {
//            XCTAssertEqual($0.status, .ok)
//        }
//    }
}

extension CO₂Tests {
    // for code coverage
    func testProperties() throws {
        app.routes.get("foo", use: sublimate(in: .transaction) { rq -> Void in
            _ = rq.auth
            _ = rq.headers
            _ = rq.content
            _ = rq.headers
            _ = rq.parameters
            _ = rq.client
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            XCTAssertEqual($0.status, .ok)
        }
    }
}

private struct Encodable: ResponseEncodable {
    func encodeResponse(for request: Request) -> EventLoopFuture<Response> {
        struct Encodable: Swift.Encodable {
            let foo: Bool
        }
        do {
            let data = try JSONEncoder().encode(Encodable(foo: foo))
            var headers = HTTPHeaders()
            headers.add(name: .contentType, value: "application/json")
            let rsp = Response(status: .ok, headers: headers, body: .init(data: data))
            return request.eventLoop.makeSucceededFuture(rsp)
        } catch {
            return request.eventLoop.makeFailedFuture(error)
        }
    }

    let foo: Bool
}

private struct Decodable: Swift.Decodable {
    let foo: Bool
}

private struct Authenticatable: Vapor.Authenticatable {
    var name: String
}

private struct UserAuthenticator: BasicAuthenticator {
    typealias User = Authenticatable

    func authenticate(basic: BasicAuthorization, for request: Request) -> EventLoopFuture<Void> {
        request.auth.login(User(name: "CO₂"))
        return request.eventLoop.makeSucceededFuture(())
   }
}
