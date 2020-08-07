import Foundation
import Sublimate
import Fluent
import XCTest
import Vapor

class SublimateModelMiddlewareTests: CO₂TestCase {

    override var migrations: [Migration] {
        [Model.Migration(), SoftDeleteModel.Migration()]
    }

    func testCreate() throws {
        class MW: SublimateModelMiddleware {
            func create(model: Model, on db: CO₂DB, next: AnyModelResponder) throws {
                XCTAssertEqual(model.id, .zero)
                try next.create(model, on: db.db).wait()
            }
        }

        app.databases.middleware.use(MW())

        app.routes.get("foo", use: sublimate { rq -> Model in
            XCTAssertFalse(rq.db.inTransaction)
            return try Model().create(on: rq)
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            XCTAssertEqual(try $0.content.decode(Model.self).id, .zero)
            XCTAssertEqual($0.status, .ok)
        }
    }

    func testUpdate() throws {
        class MW: SublimateModelMiddleware {
            func update(model: Model, on db: CO₂DB, next: AnyModelResponder) throws {
                XCTAssertFalse(model.foo)
                XCTAssertEqual(model.id, .zero)
                model.foo = true
                try next.update(model, on: db.db).wait()
            }
        }

        app.databases.middleware.use(MW())

        app.routes.get("foo", use: sublimate { rq -> Model in
            XCTAssertFalse(rq.db.inTransaction)
            let model = Model()
            XCTAssertFalse(model.foo)
            model.$id.exists = true
            let rv = try model.update(on: rq)
            XCTAssertTrue(model.foo)
            XCTAssertTrue(rv.foo)
            return rv
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            XCTAssertEqual($0.status, .ok)
            let model = try $0.content.decode(Model.self)
            XCTAssertTrue(model.foo)
            XCTAssertEqual(model.id, .zero)
        }
    }

    func testDelete() throws {
        class MW: SublimateModelMiddleware {
            func delete(model: Model, force: Bool, on db: CO₂DB, next: AnyModelResponder) throws {
                XCTAssertEqual(model.id, .zero)
                try next.delete(model, force: force, on: db.db).wait()
            }
        }

        app.databases.middleware.use(MW())

        app.routes.get("foo", use: sublimate { rq in
            XCTAssertFalse(rq.db.inTransaction)
            let model = try Model().create(on: rq)
            XCTAssertEqual(try Model.query(on: rq).first(or: .abort).id, .zero)
            try model.delete(on: rq)
            XCTAssertNil(try Model.query(on: rq).first())
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            XCTAssertEqual($0.status, .ok)
        }
    }

    func testSoftDelete() throws {
        class MW: SublimateModelMiddleware {
            func softDelete(model: SoftDeleteModel, on db: CO₂DB, next: AnyModelResponder) throws {
                XCTAssertEqual(model.id, .zero)
                try next.softDelete(model, on: db.db).wait()
            }
        }

        app.databases.middleware.use(MW())

        app.routes.get("foo", use: sublimate { rq in
            XCTAssertFalse(rq.db.inTransaction)
            let model = try SoftDeleteModel().create(on: rq)
            XCTAssertEqual(try SoftDeleteModel.query(on: rq).first(or: .abort).id, .zero)
            try model.delete(on: rq)
            XCTAssertNil(try SoftDeleteModel.query(on: rq).first())
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            XCTAssertEqual($0.status, .ok)
        }
    }

    func testRestore() throws {
        class MW: SublimateModelMiddleware {
            func restore(model: SoftDeleteModel, on db: CO₂DB, next: AnyModelResponder) throws {
                XCTAssertEqual(model.id, .zero)
                try next.restore(model, on: db.db).wait()
            }
        }

        app.databases.middleware.use(MW())

        app.routes.get("foo", use: sublimate { rq in
            XCTAssertFalse(rq.db.inTransaction)
            let model = try SoftDeleteModel().create(on: rq)
            XCTAssertEqual(try SoftDeleteModel.query(on: rq).first(or: .abort).id, .zero)
            try model.delete(on: rq)
            XCTAssertNil(try SoftDeleteModel.query(on: rq).first())
            try model.restore(on: rq)
            XCTAssertEqual(try SoftDeleteModel.query(on: rq).first(or: .abort).id, .zero)
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            XCTAssertEqual($0.status, .ok)
        }
    }

    func testDefaults() throws {
        class MW1: SublimateModelMiddleware {
            typealias Model = Tests.Model
        }
        class MW2: SublimateModelMiddleware {
            typealias Model = SoftDeleteModel
        }

        app.databases.middleware.use(MW1())
        app.databases.middleware.use(MW2())

        app.routes.get("foo", use: sublimate { rq in
            do {
                XCTAssertFalse(rq.db.inTransaction)
                let model = try Model().create(on: rq)
                XCTAssertFalse(model.foo)
                model.foo = true
                try model.update(on: rq)
                XCTAssertTrue(model.foo)
                try model.delete(on: rq)
            }
            do {
                XCTAssertFalse(rq.db.inTransaction)
                let model = try SoftDeleteModel().create(on: rq)
                XCTAssertEqual(try SoftDeleteModel.query(on: rq).first(or: .abort).id, .zero)
                try model.delete(on: rq)
                XCTAssertNil(try SoftDeleteModel.query(on: rq).first())
                try model.restore(on: rq)
                XCTAssertEqual(try SoftDeleteModel.query(on: rq).first(or: .abort).id, .zero)
            }
        })

        try app.testable(method: .inMemory).test(.GET, "foo") {
            XCTAssertEqual($0.status, .ok)
        }
    }
}

private final class Model: Fluent.Model, Content {
    static let schema = "schema1"

    @ID(key: .id) var id: UUID?
    @Field(key: "foo") var foo: Bool

    init() {
        id = .zero
        foo = false
    }

    struct Migration: Fluent.Migration {
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(Model.schema)
                .id()
                .field("foo", .bool, .required)
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(Model.schema).delete()
        }

        var name: String { "Migration1" }
    }
}


private final class SoftDeleteModel: Fluent.Model, Content {
    static let schema = "schema2"

    @ID(key: .id) var id: UUID?
    @Field(key: "foo") var foo: Bool
    @Timestamp(key: "deleted_at", on: .delete) var deletedAt

    init() {
        id = .zero
        foo = false
    }

    struct Migration: Fluent.Migration {
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(SoftDeleteModel.schema)
                .id()
                .field("foo", .bool, .required)
                .field("deleted_at", .datetime)
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(SoftDeleteModel.schema).delete()
        }

        var name: String { "Migration2" }
    }
}

private extension UUID {
    static var zero: Self { Self(uuidString: "00000000-0000-0000-0000-000000000000")! }
}
