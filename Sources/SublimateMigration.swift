import Dispatch
import Fluent
import SQLKit

public protocol SublimateMigration {
    func prepare(on db: CO₂DB) throws
    func revert(on db: CO₂DB) throws
    var name: String { get }
}

public extension SublimateMigration {
    var name: String { String(reflecting: Self.self) }
}

public extension CO₂DB {
    func schema(_ schema: String) -> SublimateSchemaBuilder {
        return .init(sb: db.schema(schema))
    }
}

private struct Wrapper: Migration {
    let sm: SublimateMigration

    func prepare(on db: Database) -> EventLoopFuture<Void> {
        db.transaction { db in
            DispatchQueue.global().async(on: db.eventLoop) {
                try self.sm.prepare(on: .init(db: db))
            }
        }
    }

    func revert(on db: Database) -> EventLoopFuture<Void> {
        db.transaction { db in
            DispatchQueue.global().async(on: db.eventLoop) {
                try self.sm.revert(on: .init(db: db))
            }
        }
    }

    var name: String { return sm.name }

    init(migration: SublimateMigration) {
        sm = migration
    }
}


public final class SublimateSchemaBuilder {
    public let sb: SchemaBuilder

    init(sb: SchemaBuilder) {
        self.sb = sb
    }

    @inlinable
    public func id() -> Self {
        _ = sb.id()
        return self
    }

    @inlinable
    public func field(
            _ key: FieldKey,
            _ dataType: DatabaseSchema.DataType,
            _ constraints: DatabaseSchema.FieldConstraint...
        ) -> Self {
        _ = sb.field(.definition(
            name: .key(key),
            dataType: dataType,
            constraints: constraints
        ))
        return self
    }

    @inlinable
    public func field(_ field: DatabaseSchema.FieldDefinition) -> Self {
        _ = sb.field(field)
        return self
    }

    @inlinable
    public func unique(on fields: FieldKey..., name: String? = nil) -> Self {
        _ = sb.constraint(.constraint(
            .unique(fields: fields.map { .key($0) }),
            name: name
        ))
        return self
    }

    @inlinable
    public func constraint(_ constraint: DatabaseSchema.Constraint) -> Self {
        _ = sb.constraint(constraint)
        return self
    }

    @inlinable
    public func deleteUnique(on fields: FieldKey...) -> Self {
        sb.schema.deleteConstraints.append(.constraint(
            .unique(fields: fields.map { .key($0) })
        ))
        return self
    }

    @inlinable
    public func deleteConstraint(name: String) -> Self {
        _ = sb.deleteConstraint(name: name)
        return self
    }

    @inlinable
    public func foreignKey(
            _ field: FieldKey,
            references foreignSchema: String,
            _ foreignField: FieldKey,
            onDelete: DatabaseSchema.ForeignKeyAction = .noAction,
            onUpdate: DatabaseSchema.ForeignKeyAction = .noAction,
            name: String? = nil
        ) -> Self {
        sb.schema.createConstraints.append(.constraint(
            .foreignKey(
                [.key(field)],
                foreignSchema,
                [.key(foreignField)],
                onDelete: onDelete,
                onUpdate: onUpdate
            ),
            name: name
        ))
        return self
    }

    @inlinable
    public func updateField(
            _ key: FieldKey,
            _ dataType: DatabaseSchema.DataType
        ) -> Self {
        _ = sb.updateField(key, dataType)
        return self
    }

    @inlinable
    public func updateField(_ field: DatabaseSchema.FieldUpdate) -> Self {
        _ = sb.updateField(field)
        return self
    }

    @inlinable
    public func deleteField(_ name: FieldKey) -> Self {
        _ = sb.deleteField(name)
        return self
    }

    @inlinable
    public func deleteField(_ name: DatabaseSchema.FieldName) -> Self {
        _ = sb.deleteField(name)
        return self
    }

    @inlinable
    public func ignoreExisting() -> Self {
        _ = sb.ignoreExisting()
        return self
    }

    @inlinable
    public func create() throws {
        try sb.create().wait()
    }

    @inlinable
    public func update() throws {
        try sb.update().wait()
    }

    @inlinable
    public func delete() throws {
        try sb.delete().wait()
    }
}

extension Migrations {
    public func add(_ migrations: SublimateMigration..., to id: DatabaseID? = nil) {
        add(migrations.map(Wrapper.init), to: id)
    }
}
