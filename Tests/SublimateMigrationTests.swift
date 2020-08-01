import FluentSQLiteDriver
import Foundation
@testable import Sublimate
import Fluent
import XCTest
import Vapor

class SublimateMigrationTests: CO₂TestCase {
    override var sublimateMigrations: [SublimateMigration] {[
        Model.Migration1(),
        Migration2(),
        Model.Migration3()
    ]}

    func test() {
        // for coverage
        let model = Model()
        _ = model.id
        _ = model.foo
        _ = model.bar

        app.migrations.add(Model.Migration1())
    }
}

private final class Model: Fluent.Model, Content {
    static let schema = "schema"

    @ID(key: .id) var id: UUID?
    @Field(key: "foo") var foo: Bool
    @Field(key: "bar") var bar: UUID

    init() {
        id = .zero
        foo = false
        bar = .zero
    }

    struct Migration1: SublimateMigration {
        func prepare(on database: CO₂DB) throws {
            try database.schema(Model.schema)
                .id()
                .field(.definition(name: .key(.string("bar")), dataType: .bool, constraints: [.required]))
                .updateField(.dataType(name: .key(.string("bar")), dataType: .uuid))
                .foreignKey("bar", references: "foo", .string("bar"))
                .deleteField(.key(.string("bar")))
                .field("foo", .bool, .required)
                .updateField("foo", .int)
                .deleteField("foo")
                .unique(on: "bar")
                .deleteUnique(on: "bar")
                .ignoreExisting()
                .constraint(.constraint(.unique(fields: [.key("bar")]), name: "foo_"))
                .deleteConstraint(name: "foo_")

                .create()
        }

        func revert(on database: CO₂DB) throws {
            
        }

        var name: String { "Migration1" }
    }

    struct Migration3: SublimateMigration {
        func prepare(on database: CO₂DB) throws {
            try database.schema(Model.schema).delete()
        }

        func revert(on database: CO₂DB) throws {

        }

        var name: String { "Migration3" }
    }
}


struct Migration2: SublimateMigration {
    func prepare(on database: CO₂DB) throws {
        try database.schema(Model.schema)
            // Fluent SQLite sucks
//          .updateField("foo", .int)
//          .deleteField("bar")
            .update()
    }

    func revert(on database: CO₂DB) throws {

    }
}

private extension UUID {
    static var zero: Self { Self(uuidString: "00000000-0000-0000-0000-000000000000")! }
}
