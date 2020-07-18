@testable import Sublimate
import XCTFluent
import XCTVapor
import Fluent
import XCTest
import Vapor

final class CO₂Tests: XCTestCase {
    var app: Application!

    override func setUp() {
        app = Application(.testing)
        app.databases.use(DummyDatabase.Configuration(), as: .init(string: "test"))
    }

    override func tearDown() {
        app.shutdown()
    }

    func testHTTPStatus() throws {
        app.routes.get("foo", use: sublimate { rq in
            HTTPStatus.ok
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            XCTAssertEqual($0.status, .ok)
        }
    }

    func testVoid() throws {
        var foo = false

        app.routes.get("foo", use: sublimate { rq in
            foo = true
        })

        try app.testable(method: .inMemory).test(.GET, "foo") { _ in
            XCTAssert(foo)
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

        app.routes.get("foo", use: sublimate(in: .transaction) { rq in
            XCTAssert(rq.db.inTransaction)
            foo = true
        })

        try app.testable(method: .inMemory).test(.GET, "foo") { _ in
            XCTAssert(foo)
        }
    }
}

private struct DummyDatabase: Database {
    var context: DatabaseContext {
        fatalError()
    }

    init(inTransaction: Bool = false) {
        self.inTransaction = inTransaction
    }

    let inTransaction: Bool

    struct Configuration: DatabaseConfiguration {
        func makeDriver(for databases: Databases) -> DatabaseDriver {
            Driver()
        }

        var middleware: [AnyModelMiddleware] {
            get {[]}
            set {}
        }

        init()
        {}

        struct Driver: DatabaseDriver {
            func makeDatabase(with context: DatabaseContext) -> Database {
                DummyDatabase()
            }

            func shutdown()
            {}
        }
    }

    func execute(query: DatabaseQuery, onOutput: @escaping (DatabaseOutput) -> ()) -> EventLoopFuture<Void> {
        fatalError()
    }

    func execute(schema: DatabaseSchema) -> EventLoopFuture<Void> {
        fatalError()
    }

    func execute(enum: DatabaseEnum) -> EventLoopFuture<Void> {
        fatalError()
    }

    func transaction<T>(_ closure: @escaping (Database) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
        closure(Self(inTransaction: true))
    }

    func withConnection<T>(_ closure: @escaping (Database) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
        closure(self)
    }
}
