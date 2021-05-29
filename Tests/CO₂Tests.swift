@testable import Sublimate
import XCTFluent
import XCTVapor
import Fluent
import XCTest
import Vapor

final class CO₂Tests: CO₂TestCase {
    func isOK(_ res: XCTHTTPResponse) throws { XCTAssertEqual(res.status, .ok) }

    func testHTTPStatus() throws {
        app.routes.get("foo", use: sublimate { rq -> HTTPStatus in
            XCTAssertFalse(rq.db.inTransaction)
            return .ok
        })

        try app.testable(method: .inMemory).test(.GET, "foo", afterResponse: isOK)
    }

    func testHTTPResponse() throws {
        app.routes.get("foo", use: sublimate { rq -> Response in
            XCTAssertFalse(rq.db.inTransaction)
            return Response(status: .ok)
        })

        try app.testable(method: .inMemory).test(.GET, "foo", afterResponse: isOK)
    }

    func testVoid() throws {
        var foo = false

        app.routes.get("foo", use: sublimate { rq in
            XCTAssertFalse(rq.db.inTransaction)
            foo = true
        })

        try app.testable(method: .inMemory).test(.GET, "foo", afterResponse: { _ in XCTAssert(foo) })
    }

    func testEncodable() throws {
        app.routes.get("foo", use: sublimate { rq -> Encodable in
            XCTAssertFalse(rq.db.inTransaction)
            return Encodable(foo: true)
        })

        try app.testable(method: .inMemory).test(.GET, "foo", afterResponse: {
            let rsp = try $0.content.decode(Decodable.self)
            XCTAssertEqual(rsp.foo, true)
        })
    }

    func testTransactionHTTPStatus() throws {
        app.routes.get("foo", use: sublimate(in: .transaction) { rq -> HTTPStatus in
            XCTAssert(rq.db.inTransaction)
            return .ok
        })

        try app.testable(method: .inMemory).test(.GET, "foo", afterResponse: isOK)
    }

    func testTransactionVoid() throws {
        var foo = false

        app.routes.get("foo", use: sublimate(in: .transaction) { rq in
            XCTAssert(rq.db.inTransaction)
            foo = true
        })

        try app.testable(method: .inMemory).test(.GET, "foo", afterResponse: { _ in XCTAssert(foo) })
    }

    func testTransactionHTTPResponse() throws {
        var foo = false

        app.routes.get("foo", use: sublimate(in: .transaction) { rq -> Response in
            XCTAssert(rq.db.inTransaction)
            foo = true
            return Response(status: .ok)
        })

        try app.testable(method: .inMemory).test(.GET, "foo", afterResponse: {
            try isOK($0)
            XCTAssert(foo)
        })
    }

    func testTransactionEncodable() throws {
        var foo = false

        app.routes.get("foo", use: sublimate(in: .transaction) { rq -> Encodable in
            XCTAssert(rq.db.inTransaction)
            foo = true
            return Encodable(foo: true)
        })

        try app.testable(method: .inMemory).test(.GET, "foo", afterResponse: {
            let rsp = try $0.content.decode(Decodable.self)
            XCTAssertEqual(rsp.foo, true)
            XCTAssert(foo)
        })
    }
}

extension CO₂Tests {
    func testAuthedHTTPStatus() throws {
        app.routes.grouped(UserAuthenticator()).get("foo", use: sublimate { (rq, user: Authenticatable) -> HTTPStatus in
            XCTAssertFalse(rq.db.inTransaction)
            XCTAssertEqual(user.name, "CO₂")
            return .ok
        })

        try app.testable(method: .inMemory).test(.GET, "foo", afterResponse: { XCTAssertEqual($0.status, .ok) })
    }

    func testAuthedHTTPResponse() throws {
        app.routes.grouped(UserAuthenticator()).get("foo", use: sublimate { (rq, user: Authenticatable) -> Response in
            XCTAssertFalse(rq.db.inTransaction)
            XCTAssertEqual(user.name, "CO₂")
            return Response(status: .ok)
        })

        try app.testable(method: .inMemory).test(.GET, "foo", afterResponse: { XCTAssertEqual($0.status, .ok) })
    }

    func testAuthedVoid() throws {
        app.routes.grouped(UserAuthenticator()).get("foo", use: sublimate { (rq, user: Authenticatable) -> Void in
            XCTAssertFalse(rq.db.inTransaction)
            XCTAssertEqual(user.name, "CO₂")
        })

        try app.testable(method: .inMemory).test(.GET, "foo", afterResponse: isOK)
    }

    func testAuthedEncodable() throws {
        app.routes.grouped(UserAuthenticator()).get("foo", use: sublimate { (rq, user: Authenticatable) -> Encodable in
            XCTAssertFalse(rq.db.inTransaction)
            XCTAssertEqual(user.name, "CO₂")
            return Encodable(foo: true)
        })

        try app.testable(method: .inMemory).test(.GET, "foo", afterResponse: {
            let rsp = try $0.content.decode(Decodable.self)
            XCTAssertEqual(rsp.foo, true)
            try isOK($0)
        })
    }

    func testAuthedTransactionHTTPStatus() throws {
        app.routes.grouped(UserAuthenticator()).get("foo", use: sublimate(in: .transaction) { (rq, user: Authenticatable) -> HTTPStatus in
            XCTAssert(rq.db.inTransaction)
            XCTAssertEqual(user.name, "CO₂")
            return .ok
        })

        try app.testable(method: .inMemory).test(.GET, "foo", afterResponse: isOK)
    }

    func testAuthedTransactionVoid() throws {
        app.routes.grouped(UserAuthenticator()).get("foo", use: sublimate(in: .transaction) { (rq, user: Authenticatable) -> Void in
            XCTAssert(rq.db.inTransaction)
            XCTAssertEqual(user.name, "CO₂")
        })

        try app.testable(method: .inMemory).test(.GET, "foo", afterResponse: isOK)
    }

    func testAuthedTransactionHTTPResponse() throws {
        app.routes.grouped(UserAuthenticator()).get("foo", use: sublimate(in: .transaction) { (rq, user: Authenticatable) -> Response in
            XCTAssert(rq.db.inTransaction)
            XCTAssertEqual(user.name, "CO₂")
            return Response(status: .ok)
        })

        try app.testable(method: .inMemory).test(.GET, "foo", afterResponse: isOK)
    }

    func testAuthedTransactionEncodable() throws {
        app.routes.grouped(UserAuthenticator()).get("foo", use: sublimate(in: .transaction) { (rq, user: Authenticatable) -> Encodable in
            XCTAssert(rq.db.inTransaction)
            XCTAssertEqual(user.name, "CO₂")
            return Encodable(foo: true)
        })

        try app.testable(method: .inMemory).test(.GET, "foo", afterResponse: {
            let rsp = try $0.content.decode(Decodable.self)
            XCTAssertEqual(rsp.foo, true)
            try isOK($0)
        })
    }
}

extension CO₂Tests {
    // for code coverage
    func testProperties() throws {
        app.routes.get("foo", use: sublimate(in: .transaction) { rq in
            _ = rq.auth
            _ = rq.headers
            _ = rq.content
            _ = rq.headers
            _ = rq.parameters
            _ = rq.client
            _ = rq.query
            _ = rq.logger
            _ = rq.application
        })

        try app.testable(method: .inMemory).test(.GET, "foo", afterResponse: isOK)
    }
}

private struct Encodable: ResponseEncodable {
    func encodeResponse(for request: Request) -> EventLoopFuture<Response> {
        struct Encodable: Swift.Encodable {
            let foo: Bool
        }
        let data = try! JSONEncoder().encode(Encodable(foo: foo))
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "application/json")
        let rsp = Response(status: .ok, headers: headers, body: .init(data: data))
        return request.eventLoop.makeSucceededFuture(rsp)
    }

    let foo: Bool
}

private struct Decodable: Swift.Decodable {
    let foo: Bool
}

private struct Authenticatable: Vapor.Authenticatable {
    var name: String
}

private struct UserAuthenticator: RequestAuthenticator {
    typealias User = Authenticatable

    func authenticate(request: Request) -> EventLoopFuture<Void> {
        request.auth.login(User(name: "CO₂"))
        return request.eventLoop.makeSucceededFuture(())
   }
}
